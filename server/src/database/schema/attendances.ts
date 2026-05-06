import { pgTable, timestamp, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
import { attendanceStatusEnum, syncStatusEnum } from './enums';
import { rsvps } from './rsvps';
import { sessions } from './sessions';
import { users } from './users';

export const attendances = pgTable(
  'attendances',
  {
    id: uuid('id').primaryKey(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id),
    sessionId: uuid('session_id')
      .notNull()
      .references(() => sessions.id, { onDelete: 'cascade' }),
    rsvpId: uuid('rsvp_id')
      .notNull()
      .references(() => rsvps.id),
    status: attendanceStatusEnum('status').notNull(),
    syncStatus: syncStatusEnum('sync_status').notNull().default('PENDING'),
    checkedInAt: timestamp('checked_in_at', { withTimezone: true }).notNull(),
    syncedAt: timestamp('synced_at', { withTimezone: true }),
    createdAt: timestamp('created_at', { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_attendance_user_session').on(table.userId, table.sessionId),
  ],
);
