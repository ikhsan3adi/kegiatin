import { Inject, Injectable } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { uuidv7 } from 'uuidv7';
import { DRIZZLE } from '../../../database/drizzle.provider';
import type { DrizzleDB } from '../../../database/drizzle.provider';
import { archives } from '../../../database/schema';
import { IArchiveRepository } from './archive.repository';
import {
  IArchive,
  ICreateArchiveData,
  ArchiveType,
} from '../domain/archive.types';

@Injectable()
export class DrizzleArchiveRepository implements IArchiveRepository {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async create(data: ICreateArchiveData): Promise<IArchive> {
    const [row] = await this.db
      .insert(archives)
      .values({
        id: uuidv7(),
        sessionId: data.sessionId,
        title: data.title,
        type: data.type,
        fileUrl: data.fileUrl,
      })
      .returning();

    return this.mapArchive(row);
  }

  async findBySessionId(sessionId: string): Promise<IArchive[]> {
    const rows = await this.db
      .select()
      .from(archives)
      .where(eq(archives.sessionId, sessionId))
      .orderBy(archives.createdAt);

    return rows.map((row) => this.mapArchive(row));
  }

  async findById(id: string): Promise<IArchive | null> {
    const [row] = await this.db
      .select()
      .from(archives)
      .where(eq(archives.id, id))
      .limit(1);

    return row ? this.mapArchive(row) : null;
  }

  async delete(id: string): Promise<void> {
    await this.db.delete(archives).where(eq(archives.id, id));
  }

  private mapArchive(row: typeof archives.$inferSelect): IArchive {
    return {
      id: row.id,
      sessionId: row.sessionId,
      title: row.title,
      type: row.type as ArchiveType,
      fileUrl: row.fileUrl,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }
}
