/* eslint-disable @typescript-eslint/no-unsafe-argument */
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { createConfiguredTestApp } from './test-app.factory';

function ensureAuthEnv(): void {
  process.env.JWT_ACCESS_SECRET ??=
    'kegiatin_access_secret_change_in_production';
  process.env.JWT_REFRESH_SECRET ??=
    'kegiatin_refresh_secret_change_in_production';
}

const hasDatabase = Boolean(process.env.DATABASE_URL);

(hasDatabase ? describe : describe.skip)('App bootstrap (e2e)', () => {
  let app: INestApplication;

  beforeAll(() => {
    ensureAuthEnv();
  });

  beforeEach(async () => {
    app = await createConfiguredTestApp();
  });

  afterEach(async () => {
    await app.close();
  });

  it('GET /api/events without token returns 401', () => {
    return request(app.getHttpServer()).get('/api/events').expect(401);
  });
});
