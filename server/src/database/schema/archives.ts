import { pgTable, timestamp, uuid, varchar } from 'drizzle-orm/pg-core';
import { archiveTypeEnum } from './enums';
import { sessions } from './sessions';

export const archives = pgTable('archives', {
  id: uuid('id').primaryKey(),
  sessionId: uuid('session_id')
    .notNull()
    .references(() => sessions.id, { onDelete: 'cascade' }),
  title: varchar('title', { length: 500 }).notNull(),
  type: archiveTypeEnum('type').notNull(),
  fileUrl: varchar('file_url', { length: 1024 }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
