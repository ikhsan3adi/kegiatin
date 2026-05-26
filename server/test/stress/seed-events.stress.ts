/* eslint-disable @typescript-eslint/no-unsafe-argument */

import request from 'supertest';
import postgres from 'postgres';
import { INestApplication } from '@nestjs/common';
import { createConfiguredTestApp } from '../test-app.factory';
import { fakeCreateEventDto } from './helpers/faker-factory';
import {
  createAdmin,
  ensureAuthEnv,
  printStressResults,
} from './helpers/auth-helper';
import { cleanupStressTestData } from './helpers/cleanup';
import { EventType } from '../../src/modules/events/domain/event.types';

const COUNT = 200;

describe('Stress: Mass Event + Session Creation', () => {
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

  it(`should create ${COUNT} events with nested sessions`, async () => {
    const admin = await createAdmin(app, sql);
    const latencies: number[] = [];
    let errors = 0;

    for (let i = 0; i < COUNT; i++) {
      const isSeries = i % 2 === 0;
      const dto = fakeCreateEventDto({
        type: isSeries ? EventType.SERIES : EventType.SINGLE,
        sessionCount: isSeries ? 3 : 1,
      });

      const start = Date.now();
      const res = await request(app.getHttpServer())
        .post('/api/events')
        .set('Authorization', `Bearer ${admin.token}`)
        .send(dto);

      latencies.push(Date.now() - start);

      if (res.status !== 201) {
        errors++;
      }
    }

    printStressResults(`Create ${COUNT} events`, latencies, errors);

    expect(errors).toBe(0);
  }, 300_000);
});
