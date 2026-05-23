import {
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { and, eq } from 'drizzle-orm';
import { DRIZZLE } from '../../database/drizzle.provider';
import type { DrizzleDB } from '../../database/drizzle.provider';
import { sessions, attendances } from '../../database/schema';
import { IArchiveRepository } from './repositories/archive.repository';
import { CreateArchiveDto } from './dto/create-archive.dto';

@Injectable()
export class ArchivesService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly archiveRepo: IArchiveRepository,
  ) {}

  async create(sessionId: string, dto: CreateArchiveDto) {
    const [session] = await this.db
      .select({ id: sessions.id })
      .from(sessions)
      .where(eq(sessions.id, sessionId))
      .limit(1);

    if (!session) throw new NotFoundException('Sesi tidak ditemukan');

    return this.archiveRepo.create({
      sessionId,
      title: dto.title,
      type: dto.type,
      fileUrl: dto.fileUrl,
    });
  }

  async findBySessionId(sessionId: string, userId: string, userRole: string) {
    const [session] = await this.db
      .select({ id: sessions.id })
      .from(sessions)
      .where(eq(sessions.id, sessionId))
      .limit(1);

    if (!session) throw new NotFoundException('Sesi tidak ditemukan');

    if (userRole !== 'ADMIN') {
      const [attendance] = await this.db
        .select({ status: attendances.status })
        .from(attendances)
        .where(
          and(
            eq(attendances.userId, userId),
            eq(attendances.sessionId, sessionId),
          ),
        )
        .limit(1);

      const isVerified =
        attendance?.status === 'PRESENT' || attendance?.status === 'LATE';

      if (!isVerified) {
        throw new ForbiddenException(
          'Akses materi hanya untuk peserta dengan status PRESENT atau LATE',
        );
      }
    }

    return this.archiveRepo.findBySessionId(sessionId);
  }

  async delete(id: string) {
    const archive = await this.archiveRepo.findById(id);
    if (!archive) throw new NotFoundException('Materi tidak ditemukan');

    await this.archiveRepo.delete(id);
  }
}
