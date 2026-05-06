export enum EventType {
  SINGLE = 'SINGLE',
  SERIES = 'SERIES',
}

export enum EventStatus {
  DRAFT = 'DRAFT',
  PUBLISHED = 'PUBLISHED',
  ONGOING = 'ONGOING',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}

export enum EventVisibility {
  OPEN = 'OPEN',
  INVITE_ONLY = 'INVITE_ONLY',
}

export enum SessionStatus {
  SCHEDULED = 'SCHEDULED',
  ONGOING = 'ONGOING',
  COMPLETED = 'COMPLETED',
  POSTPONED = 'POSTPONED',
}

export interface ISession {
  id: string;
  title: string;
  startTime: Date;
  endTime: Date;
  location: string | null;
  capacity: number | null;
  order: number;
  status: SessionStatus;
  eventId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface IEvent {
  id: string;
  title: string;
  description: string;
  type: EventType;
  status: EventStatus;
  visibility: EventVisibility;
  location: string;
  contactPerson: string;
  imageUrl: string | null;
  maxParticipants: number | null;
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface IEventWithSessions {
  event: IEvent;
  sessions: ISession[];
}

/** Flat response shape — matches OpenAPI EventResponse (sessions embedded). */
export type IEventResponse = IEvent & { sessions: ISession[] };

export interface ICreateSessionData {
  title: string;
  startTime: Date;
  endTime: Date;
  location?: string | null;
  capacity?: number | null;
  order: number;
  eventId: string;
}

export interface ICreateEventData {
  title: string;
  description?: string;
  type: EventType;
  visibility: EventVisibility;
  location?: string;
  contactPerson?: string;
  imageUrl?: string | null;
  maxParticipants?: number | null;
  createdBy: string;
}

export interface IEventFilter {
  page: number;
  limit: number;
  status?: EventStatus;
  /** Match any of the given statuses. Ignored when `status` is set. */
  statusIn?: EventStatus[];
  type?: EventType;
  visibility?: EventVisibility;
  search?: string;
}
