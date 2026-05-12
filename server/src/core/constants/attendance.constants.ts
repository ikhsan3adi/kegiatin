/** Minutes after session start still counted as PRESENT (then LATE). Tunable org policy. */
export const ATTENDANCE_LATE_GRACE_MINUTES = 15;

export const ATTENDANCE_LATE_GRACE_MS =
  ATTENDANCE_LATE_GRACE_MINUTES * 60 * 1000;
