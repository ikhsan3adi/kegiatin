import { Inject, Injectable } from '@nestjs/common';
import { and, count, desc, eq } from 'drizzle-orm';
import { uuidv7 } from 'uuidv7';
import { DRIZZLE } from '../../../database/drizzle.provider';
import type { DrizzleDB } from '../../../database/drizzle.provider';
import { attendances, users } from '../../../database/schema';
import { AttendanceDuplicateError } from '../domain/attendance.errors';
import { IAttendanceRepository } from '../domain/attendance.repository';
import {
  AttendanceStatus,
  AttendanceSyncStatus,
  IAttendance,
  IAttendanceListFilter,
  IAttendanceWithUser,
  ICreateAttendanceData,
} from '../domain/attendance.types';

function isUniqueViolation(err: unknown): boolean {
  return (
    typeof err === 'object' &&
    err !== null &&
    'code' in err &&
    (err as { code: string }).code === '23505'
  );
}

@Injectable()
export class DrizzleAttendanceRepository implements IAttendanceRepository {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async create(data: ICreateAttendanceData): Promise<IAttendance> {
    try {
      const [row] = await this.db
        .insert(attendances)
        .values({
          id: uuidv7(),
          userId: data.userId,
          sessionId: data.sessionId,
          rsvpId: data.rsvpId,
          status: data.status,
          syncStatus: data.syncStatus,
          checkedInAt: data.checkedInAt,
          syncedAt: data.syncedAt,
        })
        .returning();
      return this.mapAttendance(row);
    } catch (err) {
      if (isUniqueViolation(err)) {
        throw new AttendanceDuplicateError();
      }
      throw err;
    }
  }

  async findByUserAndSession(
    userId: string,
    sessionId: string,
  ): Promise<IAttendance | null> {
    const rows = await this.db
      .select()
      .from(attendances)
      .where(
        and(
          eq(attendances.userId, userId),
          eq(attendances.sessionId, sessionId),
        ),
      )
      .limit(1);
    return rows[0] ? this.mapAttendance(rows[0]) : null;
  }

  async findBySessionId(
    sessionId: string,
    filter: IAttendanceListFilter,
  ): Promise<{ rows: IAttendanceWithUser[]; total: number }> {
    const offset = (filter.page - 1) * filter.limit;
    const whereClause = eq(attendances.sessionId, sessionId);

    const [dataRows, [{ total }]] = await Promise.all([
      this.db
        .select({
          attendance: attendances,
          user: {
            displayName: users.displayName,
            npa: users.npa,
            cabang: users.cabang,
            photoUrl: users.photoUrl,
          },
        })
        .from(attendances)
        .innerJoin(users, eq(attendances.userId, users.id))
        .where(whereClause)
        .orderBy(desc(attendances.checkedInAt))
        .offset(offset)
        .limit(filter.limit),
      this.db.select({ total: count() }).from(attendances).where(whereClause),
    ]);

    const rows: IAttendanceWithUser[] = dataRows.map((r) => ({
      ...this.mapAttendance(r.attendance),
      user: r.user,
    }));

    return { rows, total };
  }

  private mapAttendance(row: typeof attendances.$inferSelect): IAttendance {
    return {
      id: row.id,
      userId: row.userId,
      sessionId: row.sessionId,
      rsvpId: row.rsvpId,
      status: row.status as AttendanceStatus,
      syncStatus: row.syncStatus as AttendanceSyncStatus,
      checkedInAt: row.checkedInAt,
      syncedAt: row.syncedAt ?? null,
      createdAt: row.createdAt,
    };
  }
}
