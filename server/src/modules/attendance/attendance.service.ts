import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { IEventRepository } from '../events/domain/event.repository';
import { IRsvpRepository } from '../rsvp/domain/rsvp.repository';
import { AttendanceDuplicateError } from './domain/attendance.errors';
import { IAttendanceRepository } from './domain/attendance.repository';
import {
  attendanceStatusFromCheckIn,
  canCheckInForAttendance,
  isRsvpEligibleForCheckIn,
} from './domain/attendance.rules';
import {
  AttendanceSyncStatus,
  IAttendance,
  IAttendanceLookupResult,
  IAttendanceWithUser,
  ISyncAttendanceResult,
  ISyncRecordResult,
  ResolveOutcome,
} from './domain/attendance.types';
import { AttendanceListQueryDto } from './dto/attendance-list-query.dto';
import { ScanQrDto } from './dto/scan-qr.dto';
import {
  SyncAttendanceBatchDto,
  SyncAttendanceRecordDto,
} from './dto/sync-attendance.dto';

@Injectable()
export class AttendanceService {
  constructor(
    private readonly attendanceRepo: IAttendanceRepository,
    private readonly rsvpRepo: IRsvpRepository,
    private readonly eventRepo: IEventRepository,
  ) {}

  async scan(dto: ScanQrDto): Promise<IAttendance> {
    const checkedInAt = new Date();
    const outcome = await this.resolveCheckIn(
      dto.qrToken,
      dto.sessionId,
      checkedInAt,
    );
    if (!outcome.ok) {
      throw new BadRequestException(outcome.reason);
    }

    const existing = await this.attendanceRepo.findByUserAndSession(
      outcome.rsvp.userId,
      dto.sessionId,
    );
    if (existing) {
      throw new ConflictException('Sudah tercatat hadir untuk sesi ini');
    }

    try {
      return await this.attendanceRepo.create({
        userId: outcome.rsvp.userId,
        sessionId: dto.sessionId,
        rsvpId: outcome.rsvp.id,
        status: outcome.status,
        checkedInAt,
        syncStatus: AttendanceSyncStatus.SYNCED,
        syncedAt: checkedInAt,
      });
    } catch (e) {
      if (e instanceof AttendanceDuplicateError) {
        throw new ConflictException('Sudah tercatat hadir untuk sesi ini');
      }
      throw e;
    }
  }

  async sync(dto: SyncAttendanceBatchDto): Promise<ISyncAttendanceResult> {
    const results: ISyncRecordResult[] = [];
    let synced = 0;
    let conflict = 0;
    let invalid = 0;

    for (const rec of dto.records) {
      const r = await this.syncOneRecord(rec);
      results.push(r);
      if (r.status === 'SYNCED') synced++;
      else if (r.status === 'CONFLICT') conflict++;
      else invalid++;
    }

    return {
      results,
      summary: { synced, conflict, invalid },
    };
  }

  private async syncOneRecord(
    rec: SyncAttendanceRecordDto,
  ): Promise<ISyncRecordResult> {
    const checkedInAt = new Date(rec.checkedInAt);
    const outcome = await this.resolveCheckIn(
      rec.qrToken,
      rec.sessionId,
      checkedInAt,
    );
    if (!outcome.ok) {
      return {
        localId: rec.localId,
        status: 'INVALID',
        reason: outcome.reason,
      };
    }

    const existing = await this.attendanceRepo.findByUserAndSession(
      outcome.rsvp.userId,
      rec.sessionId,
    );
    if (existing) {
      return {
        localId: rec.localId,
        status: 'CONFLICT',
        serverId: existing.id,
        reason: 'Sudah ada presensi untuk peserta di sesi ini',
      };
    }

    try {
      const created = await this.attendanceRepo.create({
        userId: outcome.rsvp.userId,
        sessionId: rec.sessionId,
        rsvpId: outcome.rsvp.id,
        status: outcome.status,
        checkedInAt,
        syncStatus: AttendanceSyncStatus.SYNCED,
        syncedAt: new Date(),
      });
      return {
        localId: rec.localId,
        status: 'SYNCED',
        serverId: created.id,
      };
    } catch (e) {
      if (e instanceof AttendanceDuplicateError) {
        const row = await this.attendanceRepo.findByUserAndSession(
          outcome.rsvp.userId,
          rec.sessionId,
        );
        return {
          localId: rec.localId,
          status: 'CONFLICT',
          serverId: row?.id,
          reason: 'Sudah ada presensi untuk peserta di sesi ini',
        };
      }
      throw e;
    }
  }

  async listBySession(
    sessionId: string,
    query: AttendanceListQueryDto,
  ): Promise<{
    data: IAttendanceWithUser[];
    meta: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  }> {
    const session = await this.eventRepo.findSessionById(sessionId);
    if (!session) {
      throw new NotFoundException('Sesi tidak ditemukan');
    }

    const { rows, total } = await this.attendanceRepo.findBySessionId(
      sessionId,
      { page: query.page, limit: query.limit },
    );

    return {
      data: rows,
      meta: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages: Math.ceil(total / query.limit) || 0,
      },
    };
  }

  async lookup(
    qrToken: string,
    sessionId: string,
  ): Promise<IAttendanceLookupResult> {
    const session = await this.eventRepo.findSessionById(sessionId);
    if (!session) {
      throw new NotFoundException('Sesi tidak ditemukan');
    }

    const rsvp = await this.rsvpRepo.findByQrToken(qrToken);
    if (!rsvp) {
      throw new NotFoundException('QR tidak dikenali');
    }

    const event = await this.eventRepo.findEventById(session.eventId);
    if (!event) {
      throw new NotFoundException('Event tidak ditemukan');
    }

    let mismatch: string | null = null;
    if (rsvp.eventId !== session.eventId) {
      mismatch = 'QR tidak untuk event sesi ini';
    } else if (!isRsvpEligibleForCheckIn(rsvp.status)) {
      mismatch = 'RSVP tidak aktif untuk presensi';
    } else if (!canCheckInForAttendance(event.status, session.status)) {
      mismatch = 'Event atau sesi tidak membuka presensi';
    }

    const user = await this.eventRepo.findUserBriefById(rsvp.userId);
    if (!user) {
      throw new NotFoundException('Pengguna tidak ditemukan');
    }

    return {
      validForSession: mismatch === null,
      rsvpId: rsvp.id,
      userId: rsvp.userId,
      eventId: rsvp.eventId,
      sessionId,
      user: {
        displayName: user.displayName,
        npa: user.npa,
        cabang: user.cabang,
        photoUrl: user.photoUrl,
      },
      ...(mismatch ? { reason: mismatch } : {}),
    };
  }

  private async resolveCheckIn(
    qrToken: string,
    sessionId: string,
    checkedInAt: Date,
  ): Promise<ResolveOutcome> {
    const session = await this.eventRepo.findSessionById(sessionId);
    if (!session) {
      return { ok: false, reason: 'Sesi tidak ditemukan' };
    }

    const rsvp = await this.rsvpRepo.findByQrToken(qrToken);
    if (!rsvp) {
      return { ok: false, reason: 'QR tidak valid atau tidak terdaftar' };
    }

    if (rsvp.eventId !== session.eventId) {
      return { ok: false, reason: 'QR tidak untuk sesi kegiatan ini' };
    }

    if (!isRsvpEligibleForCheckIn(rsvp.status)) {
      return { ok: false, reason: 'RSVP tidak aktif untuk presensi' };
    }

    const event = await this.eventRepo.findEventById(session.eventId);
    if (!event) {
      return { ok: false, reason: 'Event tidak ditemukan' };
    }

    if (!canCheckInForAttendance(event.status, session.status)) {
      return {
        ok: false,
        reason: 'Presensi tidak dibuka untuk status event/sesi saat ini',
      };
    }

    const status = attendanceStatusFromCheckIn(session.startTime, checkedInAt);

    return { ok: true, rsvp, session, event, status };
  }
}
