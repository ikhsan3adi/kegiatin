/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-argument */

import request from 'supertest';
import postgres from 'postgres';
import crypto from 'crypto';
import { INestApplication } from '@nestjs/common';
import { createConfiguredTestApp } from '../test-app.factory';
import {
  createAdmin,
  ensureAuthEnv,
  printStressResults,
  runInBatches,
} from './helpers/auth-helper';
import { cleanupStressTestData } from './helpers/cleanup';

const CONCURRENT_READERS = 100;
const EVENTS_TO_SEED = 200;

describe('Stress: Read Load', () => {
  let app: INestApplication;
  let sql: ReturnType<typeof postgres>;

  beforeAll(async () => {
    ensureAuthEnv();
    app = await createConfiguredTestApp();
    sql = postgres(process.env.DATABASE_URL!);
    await cleanupStressTestData(sql);
  }, 30_000);

  afterAll(async () => {
    await cleanupStressTestData(sql);
    await app.close();
    await sql.end({ timeout: 1 });
  });

  it(`should handle ${CONCURRENT_READERS} concurrent reading requests on ${EVENTS_TO_SEED} seeded events`, async () => {
    const admin = await createAdmin(app, sql);

    // 1. Seed 200 events and sessions via SQL directly
    console.log(`Seeding ${EVENTS_TO_SEED} events and sessions via SQL...`);
    const eventRows = [];
    const sessionRows = [];

    for (let i = 0; i < EVENTS_TO_SEED; i++) {
      const eventId = crypto.randomUUID();
      const isSeries = i % 2 === 0;
      const title = `Event Stress Seed ${i}`;

      eventRows.push({
        id: eventId,
        title,
        description: 'Seeded for read load stress testing',
        type: isSeries ? 'SERIES' : 'SINGLE',
        status: 'PUBLISHED',
        visibility: 'OPEN',
        location: 'Jl. Merdeka No. 4',
        contactPerson: 'Admin Test 08123456789',
        createdById: admin.id,
      });

      const sessionCount = isSeries ? 3 : 1;
      for (let s = 0; s < sessionCount; s++) {
        sessionRows.push({
          id: crypto.randomUUID(),
          title: `Session ${s + 1} of Event ${i}`,
          startTime: new Date(Date.now() + 3_600_000).toISOString(),
          endTime: new Date(Date.now() + 7_200_000).toISOString(),
          location: 'Session Room A',
          order: s + 1,
          status: 'SCHEDULED',
          eventId,
        });
      }
    }

    await sql.begin(async (tx) => {
      for (const ev of eventRows) {
        await tx`
          INSERT INTO events (id, title, description, type, status, visibility, location, contact_person, created_by_id)
          VALUES (${ev.id}, ${ev.title}, ${ev.description}, ${ev.type}, ${ev.status}, ${ev.visibility}, ${ev.location}, ${ev.contactPerson}, ${ev.createdById})
        `;
      }
      for (const ses of sessionRows) {
        await tx`
          INSERT INTO sessions (id, title, start_time, end_time, location, "order", status, event_id)
          VALUES (${ses.id}, ${ses.title}, ${ses.startTime}, ${ses.endTime}, ${ses.location}, ${ses.order}, ${ses.status}, ${ses.eventId})
        `;
      }
    });
    console.log('Events seeded.');

    // 2. Perform 100 reads in batches of 25 to avoid connection resets
    console.log(
      `Firing ${CONCURRENT_READERS} GET /events requests in batches of 25...`,
    );
    const latencies: number[] = [];
    let errors = 0;

    const indices = Array.from({ length: CONCURRENT_READERS }, (_, i) => i);
    await runInBatches(indices, 5, async () => {
      const start = Date.now();
      try {
        const res = await request(app.getHttpServer())
          .get('/api/events')
          .set('Authorization', `Bearer ${admin.token}`)
          .query({ page: 1, limit: 10, status: 'PUBLISHED' });

        latencies.push(Date.now() - start);

        if (res.status !== 200) {
          errors++;
          console.error(
            `Read failed: status ${res.status}, body: ${JSON.stringify(res.body)}`,
          );
        }
      } catch (err) {
        latencies.push(Date.now() - start);
        errors++;
        console.error(`Read threw error:`, err);
      }
    });

    printStressResults(
      `Read load ${CONCURRENT_READERS} concurrent requests`,
      latencies,
      errors,
    );

    expect(errors).toBe(0);
  }, 300_000);
});
