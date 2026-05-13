import {
  IAttendance,
  IAttendanceListFilter,
  IAttendanceWithUser,
  ICreateAttendanceData,
} from './attendance.types';

export abstract class IAttendanceRepository {
  abstract create(data: ICreateAttendanceData): Promise<IAttendance>;

  abstract findByUserAndSession(
    userId: string,
    sessionId: string,
  ): Promise<IAttendance | null>;

  abstract findBySessionId(
    sessionId: string,
    filter: IAttendanceListFilter,
  ): Promise<{ rows: IAttendanceWithUser[]; total: number }>;
}
