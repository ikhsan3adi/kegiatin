import { ATTENDANCE_LATE_GRACE_MS } from '../../../core/constants/attendance.constants';
import { EventStatus, SessionStatus } from '../../events/domain/event.types';
import { RsvpStatus } from '../../rsvp/domain/rsvp.types';
import {
  attendanceStatusFromCheckIn,
  canCheckInForAttendance,
  isRsvpEligibleForCheckIn,
} from './attendance.rules';
import { AttendanceStatus } from './attendance.types';

describe('attendance.rules', () => {
  describe('canCheckInForAttendance', () => {
    it('allows PUBLISHED + SCHEDULED', () => {
      expect(
        canCheckInForAttendance(EventStatus.PUBLISHED, SessionStatus.SCHEDULED),
      ).toBe(true);
    });

    it('allows ONGOING + ONGOING', () => {
      expect(
        canCheckInForAttendance(EventStatus.ONGOING, SessionStatus.ONGOING),
      ).toBe(true);
    });

    it('rejects DRAFT event', () => {
      expect(
        canCheckInForAttendance(EventStatus.DRAFT, SessionStatus.SCHEDULED),
      ).toBe(false);
    });

    it('rejects COMPLETED session', () => {
      expect(
        canCheckInForAttendance(EventStatus.PUBLISHED, SessionStatus.COMPLETED),
      ).toBe(false);
    });
  });

  describe('isRsvpEligibleForCheckIn', () => {
    it('allows CONFIRMED', () => {
      expect(isRsvpEligibleForCheckIn(RsvpStatus.CONFIRMED)).toBe(true);
    });

    it('rejects CANCELLED', () => {
      expect(isRsvpEligibleForCheckIn(RsvpStatus.CANCELLED)).toBe(false);
    });
  });

  describe('attendanceStatusFromCheckIn', () => {
    const start = new Date('2026-01-15T10:00:00.000Z');

    it('returns PRESENT at session start', () => {
      expect(attendanceStatusFromCheckIn(start, start)).toBe(
        AttendanceStatus.PRESENT,
      );
    });

    it('returns PRESENT within grace after start', () => {
      const checked = new Date(start.getTime() + ATTENDANCE_LATE_GRACE_MS);
      expect(attendanceStatusFromCheckIn(start, checked)).toBe(
        AttendanceStatus.PRESENT,
      );
    });

    it('returns LATE after grace', () => {
      const checked = new Date(start.getTime() + ATTENDANCE_LATE_GRACE_MS + 1);
      expect(attendanceStatusFromCheckIn(start, checked)).toBe(
        AttendanceStatus.LATE,
      );
    });
  });
});
