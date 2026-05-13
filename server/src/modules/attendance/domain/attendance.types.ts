import { IEvent, ISession } from '../../events/domain/event.types';
import { IRsvp } from '../../rsvp/domain/rsvp.types';

export enum AttendanceStatus {
  PRESENT = 'PRESENT',
  LATE = 'LATE',
  ABSENT = 'ABSENT',
}

export enum AttendanceSyncStatus {
  PENDING = 'PENDING',
  SYNCING = 'SYNCING',
  SYNCED = 'SYNCED',
  CONFLICT = 'CONFLICT',
}

export interface IAttendance {
  id: string;
  userId: string;
  sessionId: string;
  rsvpId: string;
  status: AttendanceStatus;
  syncStatus: AttendanceSyncStatus;
  checkedInAt: Date;
  syncedAt: Date | null;
  createdAt: Date;
}

export interface IAttendanceWithUser extends IAttendance {
  user: {
    displayName: string;
    npa: string | null;
    cabang: string | null;
    photoUrl: string | null;
  };
}

export interface ICreateAttendanceData {
  userId: string;
  sessionId: string;
  rsvpId: string;
  status: AttendanceStatus;
  checkedInAt: Date;
  syncStatus: AttendanceSyncStatus;
  syncedAt: Date | null;
}

export interface IAttendanceListFilter {
  page: number;
  limit: number;
}

export type SyncRecordResultStatus = 'SYNCED' | 'CONFLICT' | 'INVALID';

export interface ISyncRecordResult {
  localId: string;
  status: SyncRecordResultStatus;
  serverId?: string;
  reason?: string;
}

export interface ISyncAttendanceResult {
  results: ISyncRecordResult[];
  summary: { synced: number; conflict: number; invalid: number };
}

export interface IAttendanceLookupResult {
  validForSession: boolean;
  rsvpId: string;
  userId: string;
  eventId: string;
  sessionId: string;
  user: {
    displayName: string;
    npa: string | null;
    cabang: string | null;
    photoUrl: string | null;
  };
  reason?: string;
}

export type ResolveFailure = { ok: false; reason: string };
export type ResolveSuccess = {
  ok: true;
  rsvp: IRsvp;
  session: ISession;
  event: IEvent;
  status: AttendanceStatus;
};
export type ResolveOutcome = ResolveFailure | ResolveSuccess;
