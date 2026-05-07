import { ConfigService } from '@nestjs/config';
import { PostgresJsDatabase, drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

export const DRIZZLE = Symbol('DRIZZLE');

export type DrizzleDB = PostgresJsDatabase<typeof schema>;

export const drizzleProvider = {
  provide: DRIZZLE,
  inject: [ConfigService],
  useFactory: (config: ConfigService): DrizzleDB => {
    const connectionString = config.getOrThrow<string>('DATABASE_URL');
    const client = postgres(connectionString);
    return drizzle(client, { schema });
  },
};
