/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import request from 'supertest';
import postgres from 'postgres';
import { INestApplication } from '@nestjs/common';
import { createConfiguredTestApp } from '../test-app.factory';
import { fakeCreateEventDto, fakeSyncBatch } from './helpers/faker-factory';
import {
  createAdmin,
  createUser,
  ensureAuthEnv,
  printStressResults,
  runInBatches,
} from './helpers/auth-helper';
import { cleanupStressTestData } from './helpers/cleanup';
import { EventType } from '../../src/modules/events/domain/event.types';

const MEMBER_COUNT = 100;

describe('Stress: Full Flow End-to-End', () => {
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

  it('should run register -> login -> create -> publish -> RSVP -> scan -> sync flow', async () => {
    // Step 1: Create Admin
    console.log('Setting up Admin...');
    const admin = await createAdmin(app, sql);

    // Step 2: Register & Login 100 Members (sequentially)
    console.log(`Registering and logging in ${MEMBER_COUNT} members...`);
    const registerLatencies: number[] = [];
    const members: Array<{ id: string; email: string; token: string }> = [];
    let authErrors = 0;

    for (let i = 0; i < MEMBER_COUNT; i++) {
      const regStart = Date.now();
      try {
        const member = await createUser(app, i);
        registerLatencies.push(Date.now() - regStart);
        members.push(member);
      } catch {
        registerLatencies.push(Date.now() - regStart);
        authErrors++;
      }
    }

    printStressResults(
      'Full Flow - Register Members',
      registerLatencies,
      authErrors,
    );
    expect(authErrors).toBe(0);

    // Step 3: Admin creates and publishes event
    console.log('Creating and publishing event...');
    const eventDto = fakeCreateEventDto({ type: EventType.SINGLE });
    const eventRes = await request(app.getHttpServer())
      .post('/api/events')
      .set('Authorization', `Bearer ${admin.token}`)
      .send(eventDto)
      .expect(201);

    const eventId = eventRes.body.data.id;
    const sessionId = eventRes.body.data.sessions[0].id;

    await request(app.getHttpServer())
      .patch(`/api/events/${eventId}/publish`)
      .set('Authorization', `Bearer ${admin.token}`)
      .expect(200);

    // Step 4: 100 Members RSVP (in batches of 5 to avoid connection drops)
    console.log('Performing RSVPs in batches of 5...');
    const rsvpLatencies: number[] = [];
    const qrTokens: string[] = [];
    let rsvpErrors = 0;

    await runInBatches(members, 5, async (m) => {
      const start = Date.now();
      try {
        const res = await request(app.getHttpServer())
          .post(`/api/events/${eventId}/rsvp`)
          .set('Authorization', `Bearer ${m.token}`);

        rsvpLatencies.push(Date.now() - start);
        if (res.status === 201) {
          qrTokens.push(res.body.data.qrToken);
        } else {
          rsvpErrors++;
        }
      } catch {
        rsvpLatencies.push(Date.now() - start);
        rsvpErrors++;
      }
    });

    printStressResults('Full Flow - Member RSVPs', rsvpLatencies, rsvpErrors);
    expect(rsvpErrors).toBe(0);

    // Step 5: Admin scans 50 members' attendance (sequentially, simulating real-life check-in queue)
    console.log('Scanning 50 members sequentially...');
    const scanLatencies: number[] = [];
    let scanErrors = 0;

    for (let i = 0; i < 50; i++) {
      const start = Date.now();
      try {
        const res = await request(app.getHttpServer())
          .post('/api/attendance/scan')
          .set('Authorization', `Bearer ${admin.token}`)
          .send({ qrToken: qrTokens[i], sessionId });

        scanLatencies.push(Date.now() - start);
        if (res.status !== 201) {
          scanErrors++;
        }
      } catch {
        scanLatencies.push(Date.now() - start);
        scanErrors++;
      }
    }

    printStressResults(
      'Full Flow - Sequential QR Scans',
      scanLatencies,
      scanErrors,
    );
    expect(scanErrors).toBe(0);

    // Step 6: Admin syncs the remaining 50 members' attendance in a bulk batch (simulating offline sync)
    console.log('Syncing remaining 50 members in a bulk batch...');
    const syncEntries = qrTokens.slice(50).map((tok) => ({
      qrToken: tok,
      sessionId,
    }));
    const batchDto = fakeSyncBatch(syncEntries);

    const syncStart = Date.now();
    const syncRes = await request(app.getHttpServer())
      .post('/api/attendance/sync')
      .set('Authorization', `Bearer ${admin.token}`)
      .send(batchDto)
      .expect(200);

    const syncDuration = Date.now() - syncStart;

    console.log('\n═══ Full Flow - Bulk Sync 50 Users ═══');
    console.table({
      'Batch Size': 50,
      'Duration (ms)': syncDuration,
      'Throughput (rec/s)': (50 / (syncDuration / 1000)).toFixed(1),
      Synced: syncRes.body.data.summary.synced,
      Conflict: syncRes.body.data.summary.conflict,
      Invalid: syncRes.body.data.summary.invalid,
    });

    expect(syncRes.body.data.summary.synced).toBe(50);
  }, 600_000);
});
