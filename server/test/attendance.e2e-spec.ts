/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
import { INestApplication } from '@nestjs/common';
import postgres from 'postgres';
import request from 'supertest';
import { createConfiguredTestApp } from './test-app.factory';

function ensureAuthEnv(): void {
  process.env.JWT_ACCESS_SECRET ??=
    'kegiatin_access_secret_change_in_production';
  process.env.JWT_REFRESH_SECRET ??=
    'kegiatin_refresh_secret_change_in_production';
}

const hasDatabase = Boolean(process.env.DATABASE_URL);

(hasDatabase ? describe : describe.skip)('Attendance (e2e)', () => {
  let app: INestApplication;
  let sql: ReturnType<typeof postgres> | null = null;

  beforeAll(() => {
    ensureAuthEnv();
  });

  beforeEach(async () => {
    app = await createConfiguredTestApp();
    if (process.env.DATABASE_URL) {
      sql = postgres(process.env.DATABASE_URL);
    }
  });

  afterEach(async () => {
    await app.close();
    if (sql) {
      await sql.end({ timeout: 1 });
      sql = null;
    }
  });

  it('scan, duplicate 409, sync batch, list, lookup', async () => {
    const suffix = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    const adminEmail = `adm-${suffix}@e2e.test`;
    const memberEmail = `mem-${suffix}@e2e.test`;
    const password = 'password123';

    const regAdmin = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: adminEmail,
        password,
        displayName: 'Admin E2E',
        userType: 'UMUM',
      })
      .expect(201);

    const adminId = regAdmin.body.data.id as string;
    await sql!`
      update users set role = 'ADMIN' where id = ${adminId}
    `;

    await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: memberEmail,
        password,
        displayName: 'Member E2E',
        userType: 'UMUM',
      })
      .expect(201);

    const adminLogin = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: adminEmail, password })
      .expect(200);
    const adminToken = adminLogin.body.data.tokens.accessToken as string;

    const memberLogin = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: memberEmail, password })
      .expect(200);
    const memberToken = memberLogin.body.data.tokens.accessToken as string;

    const start = new Date(Date.now() + 3_600_000).toISOString();
    const end = new Date(Date.now() + 4_600_000).toISOString();

    const createEv = await request(app.getHttpServer())
      .post('/api/events')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        title: `E2E ${suffix}`,
        type: 'SINGLE',
        visibility: 'OPEN',
        sessions: [{ title: 'S1', startTime: start, endTime: end }],
      })
      .expect(201);

    const eventId = createEv.body.data.id as string;
    const sessionId = createEv.body.data.sessions[0].id as string;

    await request(app.getHttpServer())
      .patch(`/api/events/${eventId}/publish`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    const rsvpRes = await request(app.getHttpServer())
      .post(`/api/events/${eventId}/rsvp`)
      .set('Authorization', `Bearer ${memberToken}`)
      .expect(201);

    const qrToken = rsvpRes.body.data.qrToken as string;

    const scan1 = await request(app.getHttpServer())
      .post('/api/attendance/scan')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ qrToken, sessionId })
      .expect(201);

    expect(scan1.body.success).toBe(true);
    expect(scan1.body.data.userId).toBeDefined();

    await request(app.getHttpServer())
      .post('/api/attendance/scan')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ qrToken, sessionId })
      .expect(409);

    const syncRes = await request(app.getHttpServer())
      .post('/api/attendance/sync')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        records: [
          {
            localId: 'local-dup',
            qrToken,
            sessionId,
            checkedInAt: new Date().toISOString(),
          },
        ],
      })
      .expect(200);

    expect(syncRes.body.data.results[0].status).toBe('CONFLICT');
    expect(syncRes.body.data.summary.conflict).toBe(1);

    const listRes = await request(app.getHttpServer())
      .get(`/api/sessions/${sessionId}/attendance`)
      .set('Authorization', `Bearer ${adminToken}`)
      .query({ page: 1, limit: 10 })
      .expect(200);

    expect(listRes.body.data.length).toBe(1);
    expect(listRes.body.data[0].user.displayName).toBe('Member E2E');

    const lookup = await request(app.getHttpServer())
      .get('/api/attendance/lookup')
      .set('Authorization', `Bearer ${adminToken}`)
      .query({ qrToken, sessionId })
      .expect(200);

    expect(lookup.body.data.validForSession).toBe(true);
    expect(lookup.body.data.userId).toBe(scan1.body.data.userId);
  });

  it('rejects attendance endpoints without admin role', async () => {
    const suffix = `${Date.now()}`;
    const email = `mem-only-${suffix}@e2e.test`;
    await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email,
        password: 'password123',
        displayName: 'Member',
        userType: 'UMUM',
      })
      .expect(201);

    const login = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email, password: 'password123' })
      .expect(200);
    const token = login.body.data.tokens.accessToken as string;

    await request(app.getHttpServer())
      .post('/api/attendance/scan')
      .set('Authorization', `Bearer ${token}`)
      .send({
        qrToken: 'x',
        sessionId: '11111111-1111-7111-8111-111111111111',
      })
      .expect(403);
  });
});
