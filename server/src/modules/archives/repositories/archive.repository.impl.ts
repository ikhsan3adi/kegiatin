import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
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
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly config: ConfigService,
  ) {}

  private getAbsoluteUrl(fileUrl: string): string {
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }
    const envBaseUrl = this.config.get<string>('BASE_URL');
    const baseUrl = envBaseUrl
      ? envBaseUrl.replace(/\/$/, '')
      : `http://localhost:${this.config.get<number>('PORT', 3000)}`;
    
    const relativePath = fileUrl.startsWith('/') ? fileUrl : `/${fileUrl}`;
    return `${baseUrl}${relativePath}`;
  }

  private getRelativePath(fileUrl: string): string {
    const uploadsIndex = fileUrl.indexOf('/uploads/');
    if (uploadsIndex !== -1) {
      return fileUrl.substring(uploadsIndex);
    }
    return fileUrl;
  }

  async create(data: ICreateArchiveData): Promise<IArchive> {
    const relativePath = this.getRelativePath(data.fileUrl);
    const [row] = await this.db
      .insert(archives)
      .values({
        id: uuidv7(),
        sessionId: data.sessionId,
        title: data.title,
        type: data.type,
        fileUrl: relativePath,
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
      fileUrl: this.getAbsoluteUrl(row.fileUrl),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }
}
