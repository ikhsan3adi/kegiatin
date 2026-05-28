/* eslint-disable @typescript-eslint/no-unsafe-argument */

import request from 'supertest';
import postgres from 'postgres';
import { INestApplication } from '@nestjs/common';
import { createConfiguredTestApp } from '../test-app.factory';
import { fakeRegisterDto } from './helpers/faker-factory';
import { ensureAuthEnv, printStressResults } from './helpers/auth-helper';
import { cleanupStressTestData } from './helpers/cleanup';

const VOLUMES = [100, 500, 1000];

describe('Stress: Mass User Registration', () => {
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

  for (const count of VOLUMES) {
    it(`should register ${count} users`, async () => {
      const latencies: number[] = [];
      let errors = 0;

      for (let i = 0; i < count; i++) {
        const dto = fakeRegisterDto(i + count * 10000); // unique suffix per volume
        const start = Date.now();
        const res = await request(app.getHttpServer())
          .post('/api/auth/register')
          .send(dto);

        latencies.push(Date.now() - start);
        if (res.status !== 201) {
          errors++;
        }
      }

      printStressResults(`Register ${count} users`, latencies, errors);

      expect(errors).toBe(0);
    }, 600_000); // 10 min timeout for 1000 users with bcrypt
  }
});
