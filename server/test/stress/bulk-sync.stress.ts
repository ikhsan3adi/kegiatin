/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import request from 'supertest';
import postgres from 'postgres';
import crypto from 'crypto';
import { INestApplication } from '@nestjs/common';
import { createConfiguredTestApp } from '../test-app.factory';
import { fakeCreateEventDto, fakeSyncBatch } from './helpers/faker-factory';
import {
  createAdmin,
  ensureAuthEnv,
  printStressResults,
} from './helpers/auth-helper';
import { cleanupStressTestData } from './helpers/cleanup';
import { EventType } from '../../src/modules/events/domain/event.types';

describe('Stress: Bulk Attendance Sync', () => {
  let app: INestApplication;
  let sql: ReturnType<typeof postgres>;

  beforeAll(async () => {
    ensureAuthEnv();
    app = await createConfiguredTestApp();
    sql = postgres(process.env.DATABASE_URL!);
    await cleanupStressTestData(sql);
  }, 30_000);

  afterAll(async () => {
    if (sql) {
      await cleanupStressTestData(sql);
      await sql.end({ timeout: 1 });
    }
    if (app) {
      await app.close();
    }
  });

  it('should sync bulk attendance of sizes 50, 200, and 500', async () => {
    // 1. Setup admin + event
    const admin = await createAdmin(app, sql);
    const eventDto = fakeCreateEventDto({ type: EventType.SINGLE });

    const createRes = await request(app.getHttpServer())
      .post('/api/events')
      .set('Authorization', `Bearer ${admin.token}`)
      .send(eventDto)
      .expect(201);

    const eventId = createRes.body.data.id;
    const sessionId = createRes.body.data.sessions[0].id;

    // Publish event
    await request(app.getHttpServer())
      .patch(`/api/events/${eventId}/publish`)
      .set('Authorization', `Bearer ${admin.token}`)
      .expect(200);

    // 2. Insert 750 users and RSVPs directly in DB (bypass bcrypt bottleneck)
    console.log('Inserting 750 users and RSVPs via SQL...');
    const userRows = [];
    const rsvpRows = [];
    const timestampSuffix = Date.now();

    for (let i = 0; i < 750; i++) {
      const uId = crypto.randomUUID();
      const rId = crypto.randomUUID();
      const email = `stress-sync-usr-${i}-${timestampSuffix}@test.local`;
      const qrToken = `stress-sync-tok-${i}-${timestampSuffix}`;

      userRows.push({
        id: uId,
        email,
        password: '$2b$10$UnusedPasswordHashForStressTestsOnlyNotVerifiedXYZ',
        displayName: `Sync User ${i}`,
      });

      rsvpRows.push({
        id: rId,
        userId: uId,
        eventId,
        qrToken,
      });
    }

    await sql.begin(async (tx) => {
      for (const user of userRows) {
        await tx`
          INSERT INTO users (id, email, password, display_name, role)
          VALUES (${user.id}, ${user.email}, ${user.password}, ${user.displayName}, 'MEMBER')
        `;
      }
      for (const rsvp of rsvpRows) {
        await tx`
          INSERT INTO rsvps (id, user_id, event_id, qr_token)
          VALUES (${rsvp.id}, ${rsvp.userId}, ${rsvp.eventId}, ${rsvp.qrToken})
        `;
      }
    });
    console.log('750 records populated.');

    // 3. Test sizes
    const sizes = [50, 200, 500];
    let offset = 0;

    for (const size of sizes) {
      const targetRsvps = rsvpRows.slice(offset, offset + size);
      offset += size;

      const batchDto = fakeSyncBatch(
        targetRsvps.map((r) => ({
          qrToken: r.qrToken,
          sessionId,
        })),
      );

      const latencies: number[] = [];
      const start = Date.now();

      const res = await request(app.getHttpServer())
        .post('/api/attendance/sync')
        .set('Authorization', `Bearer ${admin.token}`)
        .send(batchDto);

      latencies.push(Date.now() - start);

      const errorCount = res.status !== 200 ? 1 : 0;
      printStressResults(`Sync batch size ${size}`, latencies, errorCount);

      expect(res.status).toBe(200);
      expect(res.body.data.summary.synced).toBe(size);
    }
  }, 300_000);
});
