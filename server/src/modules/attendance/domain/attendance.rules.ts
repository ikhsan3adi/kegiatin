import { ATTENDANCE_LATE_GRACE_MS } from '../../../core/constants/attendance.constants';
import { EventStatus, SessionStatus } from '../../events/domain/event.types';
import { RsvpStatus } from '../../rsvp/domain/rsvp.types';
import { AttendanceStatus } from './attendance.types';

/**
 * Check-in allowed when event is live-enough and session not finished.
 * PUBLISHED: early check-in before admin flips event to ONGOING.
 * ONGOING: normal operations.
 */
export function canCheckInForAttendance(
  eventStatus: EventStatus,
  sessionStatus: SessionStatus,
): boolean {
  const eventOk =
    eventStatus === EventStatus.PUBLISHED ||
    eventStatus === EventStatus.ONGOING;
  const sessionOk =
    sessionStatus === SessionStatus.SCHEDULED ||
    sessionStatus === SessionStatus.ONGOING;
  return eventOk && sessionOk;
}

export function isRsvpEligibleForCheckIn(rsvpStatus: RsvpStatus): boolean {
  return rsvpStatus === RsvpStatus.CONFIRMED;
}

export function attendanceStatusFromCheckIn(
  sessionStartTime: Date,
  checkedInAt: Date,
): AttendanceStatus {
  const threshold = new Date(
    sessionStartTime.getTime() + ATTENDANCE_LATE_GRACE_MS,
  );
  return checkedInAt.getTime() <= threshold.getTime()
    ? AttendanceStatus.PRESENT
    : AttendanceStatus.LATE;
}
