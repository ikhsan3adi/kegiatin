import {
  integer,
  pgTable,
  timestamp,
  uuid,
  varchar,
} from 'drizzle-orm/pg-core';
import { sessionStatusEnum } from './enums';
import { events } from './events';

export const sessions = pgTable('sessions', {
  id: uuid('id').primaryKey(),
  title: varchar('title', { length: 500 }).notNull(),
  startTime: timestamp('start_time', { withTimezone: true }).notNull(),
  endTime: timestamp('end_time', { withTimezone: true }).notNull(),
  location: varchar('location', { length: 500 }),
  capacity: integer('capacity'),
  order: integer('order').notNull(),
  status: sessionStatusEnum('status').notNull().default('SCHEDULED'),
  eventId: uuid('event_id')
    .notNull()
    .references(() => events.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
