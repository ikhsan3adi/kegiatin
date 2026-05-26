/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import request from 'supertest';
import postgres from 'postgres';
import { INestApplication } from '@nestjs/common';
import { createConfiguredTestApp } from '../test-app.factory';
import { fakeCreateEventDto } from './helpers/faker-factory';
import {
  createAdmin,
  createUser,
  ensureAuthEnv,
  printStressResults,
  runInBatches,
} from './helpers/auth-helper';
import { cleanupStressTestData } from './helpers/cleanup';
import { EventType } from '../../src/modules/events/domain/event.types';

const CONCURRENT = 200;

describe('Stress: Concurrent RSVP Flood', () => {
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

  it(`should handle ${CONCURRENT} concurrent RSVPs`, async () => {
    // 1. Setup admin + event
    const admin = await createAdmin(app, sql);
    const eventDto = fakeCreateEventDto({
      type: EventType.SINGLE,
      maxParticipants: CONCURRENT + 50,
    });

    const createRes = await request(app.getHttpServer())
      .post('/api/events')
      .set('Authorization', `Bearer ${admin.token}`)
      .send(eventDto)
      .expect(201);

    const eventId = createRes.body.data.id;

    // Publish event
    await request(app.getHttpServer())
      .patch(`/api/events/${eventId}/publish`)
      .set('Authorization', `Bearer ${admin.token}`)
      .expect(200);

    // 2. Register members (sequentially to avoid registration bottlenecks during metrics)
    console.log(`Registering ${CONCURRENT} members...`);
    const members = [];
    for (let i = 0; i < CONCURRENT; i++) {
      members.push(await createUser(app, i));
    }
    console.log(`All ${CONCURRENT} members registered.`);

    // 3. Fire concurrent RSVPs in batches of 5 to avoid connection drops
    console.log(`Firing ${CONCURRENT} RSVPs in batches of 5...`);
    const latencies: number[] = [];
    let errors = 0;

    await runInBatches(members, 5, async (m) => {
      const start = Date.now();
      try {
        const res = await request(app.getHttpServer())
          .post(`/api/events/${eventId}/rsvp`)
          .set('Authorization', `Bearer ${m.token}`);

        latencies.push(Date.now() - start);
        if (res.status !== 201) {
          errors++;
          console.error(
            `RSVP failed for user ${m.email}: status ${res.status}, body: ${JSON.stringify(res.body)}`,
          );
        }
      } catch (err) {
        latencies.push(Date.now() - start);
        errors++;
        console.error(`RSVP request threw error for user ${m.email}:`, err);
      }
    });

    printStressResults(
      `Concurrent RSVP ${CONCURRENT} users`,
      latencies,
      errors,
    );

    expect(errors).toBe(0);
  }, 300_000);
});
