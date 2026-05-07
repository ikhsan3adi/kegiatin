import {
  pgTable,
  timestamp,
  uniqueIndex,
  uuid,
  varchar,
} from 'drizzle-orm/pg-core';
import { rsvpStatusEnum } from './enums';
import { events } from './events';
import { users } from './users';

export const rsvps = pgTable(
  'rsvps',
  {
    id: uuid('id').primaryKey(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id),
    eventId: uuid('event_id')
      .notNull()
      .references(() => events.id, { onDelete: 'cascade' }),
    qrToken: varchar('qr_token', { length: 512 }).notNull().unique(),
    status: rsvpStatusEnum('status').notNull().default('CONFIRMED'),
    createdAt: timestamp('created_at', { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_rsvp_user_event').on(table.userId, table.eventId),
  ],
);
