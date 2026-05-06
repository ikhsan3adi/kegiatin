import { EventStatus } from '../../events/domain/event.types';
import { RsvpStatus } from './rsvp.types';

/** Event must be PUBLISHED to accept RSVPs. */
export function canRsvp(eventStatus: EventStatus): boolean {
  return eventStatus === EventStatus.PUBLISHED;
}

/** RSVP can only be cancelled while still CONFIRMED. */
export function canCancelRsvp(rsvpStatus: RsvpStatus): boolean {
  return rsvpStatus === RsvpStatus.CONFIRMED;
}

/** Returns true if participant count has reached the event cap. */
export function isEventFull(
  currentCount: number,
  maxParticipants: number | null,
): boolean {
  if (maxParticipants === null) return false;
  return currentCount >= maxParticipants;
}
