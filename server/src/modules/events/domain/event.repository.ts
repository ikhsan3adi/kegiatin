import {
  ICreateEventData,
  ICreateSessionData,
  IEvent,
  IEventFilter,
  ISession,
} from './event.types';

export abstract class IEventRepository {
  // Event
  abstract createEvent(data: ICreateEventData): Promise<IEvent>;
  abstract findEventById(id: string): Promise<IEvent | null>;
  abstract findEvents(
    filter: IEventFilter,
  ): Promise<{ events: IEvent[]; total: number }>;
  abstract updateEvent(
    id: string,
    data: Partial<IEvent>,
  ): Promise<IEvent | null>;
  abstract deleteEvent(id: string): Promise<void>;

  // Session
  abstract createSession(data: ICreateSessionData): Promise<ISession>;
  abstract findSessionById(id: string): Promise<ISession | null>;
  abstract findSessionsByEventId(eventId: string): Promise<ISession[]>;
  abstract updateSession(
    id: string,
    data: Partial<ISession>,
  ): Promise<ISession | null>;
  abstract deleteSession(id: string): Promise<void>;
  abstract countSessionsByEventId(eventId: string): Promise<number>;
  abstract deleteSessionsByEventId(eventId: string): Promise<void>;

  /** Minimal user row for attendance / lookup joins. */
  abstract findUserBriefById(userId: string): Promise<{
    displayName: string;
    npa: string | null;
    cabang: string | null;
    photoUrl: string | null;
  } | null>;
}
