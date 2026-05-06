import {
  ICreateRsvpData,
  IRsvp,
  IRsvpFilter,
  IRsvpWithUser,
  RsvpStatus,
} from './rsvp.types';

export abstract class IRsvpRepository {
  abstract create(data: ICreateRsvpData): Promise<IRsvp>;
  abstract findById(id: string): Promise<IRsvp | null>;
  abstract findByUserAndEvent(
    userId: string,
    eventId: string,
  ): Promise<IRsvp | null>;
  abstract findByQrToken(qrToken: string): Promise<IRsvp | null>;

  abstract findByEventId(
    eventId: string,
    filter: IRsvpFilter,
  ): Promise<{ rsvps: IRsvpWithUser[]; total: number }>;

  abstract findByUserId(
    userId: string,
    filter: IRsvpFilter,
  ): Promise<{ rsvps: IRsvp[]; total: number }>;

  abstract delete(id: string): Promise<void>;
  abstract countConfirmedByEventId(eventId: string): Promise<number>;
}
