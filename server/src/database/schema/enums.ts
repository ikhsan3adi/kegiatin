import { pgEnum } from 'drizzle-orm/pg-core';

export const userRoleEnum = pgEnum('user_role', ['ADMIN', 'MEMBER']);

export const eventTypeEnum = pgEnum('event_type', ['SINGLE', 'SERIES']);

export const eventStatusEnum = pgEnum('event_status', [
  'DRAFT',
  'PUBLISHED',
  'ONGOING',
  'COMPLETED',
  'CANCELLED',
]);

export const eventVisibilityEnum = pgEnum('event_visibility', [
  'OPEN',
  'INVITE_ONLY',
]);

export const sessionStatusEnum = pgEnum('session_status', [
  'SCHEDULED',
  'ONGOING',
  'COMPLETED',
  'POSTPONED',
]);

export const rsvpStatusEnum = pgEnum('rsvp_status', [
  'CONFIRMED',
  'CANCELLED',
  'WAITLIST',
]);

export const attendanceStatusEnum = pgEnum('attendance_status', [
  'PRESENT',
  'LATE',
  'ABSENT',
]);

export const syncStatusEnum = pgEnum('sync_status', [
  'PENDING',
  'SYNCING',
  'SYNCED',
  'CONFLICT',
]);
