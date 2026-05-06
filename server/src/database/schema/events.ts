import {
  pgTable,
  text,
  timestamp,
  uuid,
  varchar,
  index,
} from 'drizzle-orm/pg-core';
import { eventStatusEnum, eventTypeEnum, eventVisibilityEnum } from './enums';
import { users } from './users';

export const events = pgTable(
  'events',
  {
    id: uuid('id').primaryKey(),
    title: varchar('title', { length: 500 }).notNull(),
    description: text('description').notNull().default(''),
    type: eventTypeEnum('type').notNull(),
    status: eventStatusEnum('status').notNull().default('DRAFT'),
    visibility: eventVisibilityEnum('visibility').notNull(),
    location: varchar('location', { length: 500 }).notNull().default(''),
    contactPerson: varchar('contact_person', { length: 500 })
      .notNull()
      .default(''),
    imageUrl: varchar('image_url', { length: 512 }),
    createdById: uuid('created_by_id')
      .notNull()
      .references(() => users.id),
    createdAt: timestamp('created_at', { withTimezone: true })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp('updated_at', { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    index('idx_event_title').on(table.title),
    index('idx_event_status').on(table.status),
    index('idx_event_type').on(table.type),
    index('idx_event_created_at').on(table.createdAt),
  ],
);
