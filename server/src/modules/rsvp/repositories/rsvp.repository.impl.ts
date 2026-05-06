import { Inject, Injectable } from '@nestjs/common';
import { and, count, desc, eq } from 'drizzle-orm';
import { uuidv7 } from 'uuidv7';
import { DRIZZLE } from '../../../database/drizzle.provider';
import type { DrizzleDB } from '../../../database/drizzle.provider';
import { rsvps, users } from '../../../database/schema';
import { IRsvpRepository } from '../domain/rsvp.repository';
import {
  ICreateRsvpData,
  IRsvp,
  IRsvpFilter,
  IRsvpWithUser,
} from '../domain/rsvp.types';

@Injectable()
export class DrizzleRsvpRepository implements IRsvpRepository {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async create(data: ICreateRsvpData): Promise<IRsvp> {
    const [row] = await this.db
      .insert(rsvps)
      .values({
        id: uuidv7(),
        userId: data.userId,
        eventId: data.eventId,
        qrToken: data.qrToken,
      })
      .returning();
    return this.mapRsvp(row);
  }

  async findById(id: string): Promise<IRsvp | null> {
    const rows = await this.db
      .select()
      .from(rsvps)
      .where(eq(rsvps.id, id))
      .limit(1);
    return rows[0] ? this.mapRsvp(rows[0]) : null;
  }

  async findByUserAndEvent(
    userId: string,
    eventId: string,
  ): Promise<IRsvp | null> {
    const rows = await this.db
      .select()
      .from(rsvps)
      .where(and(eq(rsvps.userId, userId), eq(rsvps.eventId, eventId)))
      .limit(1);
    return rows[0] ? this.mapRsvp(rows[0]) : null;
  }

  async findByQrToken(qrToken: string): Promise<IRsvp | null> {
    const rows = await this.db
      .select()
      .from(rsvps)
      .where(eq(rsvps.qrToken, qrToken))
      .limit(1);
    return rows[0] ? this.mapRsvp(rows[0]) : null;
  }

  async findByEventId(
    eventId: string,
    filter: IRsvpFilter,
  ): Promise<{ rsvps: IRsvpWithUser[]; total: number }> {
    const offset = (filter.page - 1) * filter.limit;
    const whereClause = eq(rsvps.eventId, eventId);

    const [rows, [{ total }]] = await Promise.all([
      this.db
        .select({
          rsvp: rsvps,
          user: {
            displayName: users.displayName,
            npa: users.npa,
            cabang: users.cabang,
            photoUrl: users.photoUrl,
          },
        })
        .from(rsvps)
        .innerJoin(users, eq(rsvps.userId, users.id))
        .where(whereClause)
        .orderBy(desc(rsvps.createdAt))
        .offset(offset)
        .limit(filter.limit),
      this.db
        .select({ total: count() })
        .from(rsvps)
        .where(whereClause),
    ]);

    return {
      rsvps: rows.map((r) => ({
        ...this.mapRsvp(r.rsvp),
        user: {
          displayName: r.user.displayName,
          npa: r.user.npa ?? null,
          cabang: r.user.cabang ?? null,
          photoUrl: r.user.photoUrl ?? null,
        },
      })),
      total,
    };
  }

  async findByUserId(
    userId: string,
    filter: IRsvpFilter,
  ): Promise<{ rsvps: IRsvp[]; total: number }> {
    const offset = (filter.page - 1) * filter.limit;
    const whereClause = eq(rsvps.userId, userId);

    const [rows, [{ total }]] = await Promise.all([
      this.db
        .select()
        .from(rsvps)
        .where(whereClause)
        .orderBy(desc(rsvps.createdAt))
        .offset(offset)
        .limit(filter.limit),
      this.db
        .select({ total: count() })
        .from(rsvps)
        .where(whereClause),
    ]);

    return {
      rsvps: rows.map((r) => this.mapRsvp(r)),
      total,
    };
  }

  async delete(id: string): Promise<void> {
    await this.db.delete(rsvps).where(eq(rsvps.id, id));
  }

  async countConfirmedByEventId(eventId: string): Promise<number> {
    const [{ value }] = await this.db
      .select({ value: count() })
      .from(rsvps)
      .where(eq(rsvps.eventId, eventId));
    return value;
  }

  // ---------------------------------------------------------------------------
  // Mapper
  // ---------------------------------------------------------------------------

  private mapRsvp(row: typeof rsvps.$inferSelect): IRsvp {
    return {
      id: row.id,
      userId: row.userId,
      eventId: row.eventId,
      qrToken: row.qrToken,
      status: row.status as IRsvp['status'],
      createdAt: row.createdAt,
    };
  }
}
