/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import request from 'supertest';
import postgres from 'postgres';
import { INestApplication } from '@nestjs/common';
import { fakeRegisterDto } from './faker-factory';

const FIXED_PASSWORD = 'StressTest123!';

export interface UserContext {
  id: string;
  email: string;
  token: string;
}

/**
 * Ensures required JWT environment variables are set.
 */
export function ensureAuthEnv(): void {
  process.env.JWT_ACCESS_SECRET ??=
    'kegiatin_access_secret_change_in_production';
  process.env.JWT_REFRESH_SECRET ??=
    'kegiatin_refresh_secret_change_in_production';
  process.env.DATABASE_URL ??=
    'postgresql://kegiatin:kegiatin_dev@localhost:5432/kegiatin';
}

/**
 * Register a user, login, return context with token.
 */
export async function createUser(
  app: INestApplication,
  index: number,
): Promise<UserContext> {
  const dto = fakeRegisterDto(index);
  const reg = await request(app.getHttpServer())
    .post('/api/auth/register')
    .send(dto)
    .expect(201);

  const login = await request(app.getHttpServer())
    .post('/api/auth/login')
    .send({ email: dto.email, password: FIXED_PASSWORD })
    .expect(200);

  return {
    id: reg.body.data.id,
    email: dto.email,
    token: login.body.data.tokens.accessToken,
  };
}

/**
 * Promote a user to ADMIN via direct SQL.
 */
export async function promoteToAdmin(
  sql: ReturnType<typeof postgres>,
  userId: string,
): Promise<void> {
  await sql`UPDATE users SET role = 'ADMIN' WHERE id = ${userId}`;
}

/**
 * Create admin user ready to use.
 */
export async function createAdmin(
  app: INestApplication,
  sql: ReturnType<typeof postgres>,
  index = 99999,
): Promise<UserContext> {
  const user = await createUser(app, index);
  await promoteToAdmin(sql, user.id);

  // Re-login to get token with ADMIN role in JWT payload
  const login = await request(app.getHttpServer())
    .post('/api/auth/login')
    .send({ email: user.email, password: FIXED_PASSWORD })
    .expect(200);

  return { ...user, token: login.body.data.tokens.accessToken };
}

/**
 * Utility: compute percentile from sorted array.
 */
export function percentile(sortedMs: number[], pct: number): number {
  if (sortedMs.length === 0) return 0;
  const idx = Math.floor(sortedMs.length * pct);
  return sortedMs[Math.min(idx, sortedMs.length - 1)];
}

/**
 * Print a stress test result table.
 */
export function printStressResults(
  label: string,
  results: number[],
  errorCount: number,
) {
  const total = results.reduce((a, b) => a + b, 0);
  const avg = results.length > 0 ? total / results.length : 0;
  const sorted = [...results].sort((a, b) => a - b);

  console.log(`\n═══ ${label} ═══`);
  console.table({
    'Total Requests': results.length,
    'Total Time (ms)': total,
    'Avg (ms)': Math.round(avg),
    'Min (ms)': sorted[0] ?? 0,
    'P50 (ms)': percentile(sorted, 0.5),
    'P95 (ms)': percentile(sorted, 0.95),
    'P99 (ms)': percentile(sorted, 0.99),
    'Max (ms)': sorted[sorted.length - 1] ?? 0,
    'Throughput (req/s)':
      total > 0 ? (results.length / (total / 1000)).toFixed(1) : '0.0',
    Errors: errorCount,
  });
}

/**
 * Utility: Run async operations in batches to control concurrency.
 */
export async function runInBatches<T>(
  items: T[],
  batchSize: number,
  fn: (item: T) => Promise<void>,
): Promise<void> {
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    await Promise.all(batch.map(fn));
  }
}
