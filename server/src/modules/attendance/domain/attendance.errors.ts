/** Thrown when insert violates uq_attendance_user_session (race or duplicate). */
export class AttendanceDuplicateError extends Error {
  constructor() {
    super('Attendance duplicate');
    this.name = 'AttendanceDuplicateError';
  }
}
