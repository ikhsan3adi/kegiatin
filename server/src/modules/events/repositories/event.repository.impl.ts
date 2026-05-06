import { Inject, Injectable } from '@nestjs/common';
import { and, count, desc, eq, ilike, inArray } from 'drizzle-orm';
import { uuidv7 } from 'uuidv7';
import { DRIZZLE } from '../../../database/drizzle.provider';
import type { DrizzleDB } from '../../../database/drizzle.provider';
import { events, sessions } from '../../../database/schema';
import { IEventRepository } from '../domain/event.repository';
import {
  ICreateEventData,
  ICreateSessionData,
  IEvent,
  IEventFilter,
  ISession,
} from '../domain/event.types';

@Injectable()
export class DrizzleEventRepository implements IEventRepository {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  // ---------------------------------------------------------------------------
  // Event
  // ---------------------------------------------------------------------------

  async createEvent(data: ICreateEventData): Promise<IEvent> {
    const [row] = await this.db
      .insert(events)
      .values({
        id: uuidv7(),
        title: data.title,
        description: data.description ?? '',
        type: data.type,
        visibility: data.visibility,
        location: data.location ?? '',
        contactPerson: data.contactPerson ?? '',
        imageUrl: data.imageUrl ?? null,
        maxParticipants: data.maxParticipants ?? null,
        createdById: data.createdBy,
      })
      .returning();
    return this.mapEvent(row);
  }

  async findEventById(id: string): Promise<IEvent | null> {
    const rows = await this.db
      .select()
      .from(events)
      .where(eq(events.id, id))
      .limit(1);
    return rows[0] ? this.mapEvent(rows[0]) : null;
  }

  async findEvents(
    filter: IEventFilter,
  ): Promise<{ events: IEvent[]; total: number }> {
    const conditions = [];

    if (filter.status) {
      conditions.push(eq(events.status, filter.status));
    } else if (filter.statusIn && filter.statusIn.length > 0) {
      conditions.push(inArray(events.status, filter.statusIn));
    }
    if (filter.type) {
      conditions.push(eq(events.type, filter.type));
    }
    if (filter.visibility) {
      conditions.push(eq(events.visibility, filter.visibility));
    }
    if (filter.search) {
      conditions.push(ilike(events.title, `%${filter.search}%`));
    }

    const whereClause = conditions.length > 0 ? and(...conditions) : undefined;
    const offset = (filter.page - 1) * filter.limit;

    const [rows, [{ total }]] = await Promise.all([
      this.db
        .select()
        .from(events)
        .where(whereClause)
        .orderBy(desc(events.createdAt))
        .offset(offset)
        .limit(filter.limit),
      this.db.select({ total: count() }).from(events).where(whereClause),
    ]);

    return {
      events: rows.map((r) => this.mapEvent(r)),
      total,
    };
  }

  async updateEvent(id: string, data: Partial<IEvent>): Promise<IEvent | null> {
    // Map domain field names to Drizzle column names
    const setData: Record<string, unknown> = { updatedAt: new Date() };
    if (data.title !== undefined) setData.title = data.title;
    if (data.description !== undefined) setData.description = data.description;
    if (data.type !== undefined) setData.type = data.type;
    if (data.status !== undefined) setData.status = data.status;
    if (data.visibility !== undefined) setData.visibility = data.visibility;
    if (data.location !== undefined) setData.location = data.location;
    if (data.contactPerson !== undefined)
      setData.contactPerson = data.contactPerson;
    if (data.imageUrl !== undefined) setData.imageUrl = data.imageUrl;
    if (data.maxParticipants !== undefined)
      setData.maxParticipants = data.maxParticipants;

    const rows = await this.db
      .update(events)
      .set(setData)
      .where(eq(events.id, id))
      .returning();

    return rows[0] ? this.mapEvent(rows[0]) : null;
  }

  async deleteEvent(id: string): Promise<void> {
    await this.db.delete(events).where(eq(events.id, id));
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  async createSession(data: ICreateSessionData): Promise<ISession> {
    const [row] = await this.db
      .insert(sessions)
      .values({
        id: uuidv7(),
        title: data.title,
        startTime: data.startTime,
        endTime: data.endTime,
        location: data.location ?? null,
        capacity: data.capacity ?? null,
        order: data.order,
        eventId: data.eventId,
      })
      .returning();
    return this.mapSession(row);
  }

  async findSessionById(id: string): Promise<ISession | null> {
    const rows = await this.db
      .select()
      .from(sessions)
      .where(eq(sessions.id, id))
      .limit(1);
    return rows[0] ? this.mapSession(rows[0]) : null;
  }

  async findSessionsByEventId(eventId: string): Promise<ISession[]> {
    const rows = await this.db
      .select()
      .from(sessions)
      .where(eq(sessions.eventId, eventId))
      .orderBy(sessions.order);
    return rows.map((r) => this.mapSession(r));
  }

  async updateSession(
    id: string,
    data: Partial<ISession>,
  ): Promise<ISession | null> {
    const setData: Record<string, unknown> = { updatedAt: new Date() };
    if (data.title !== undefined) setData.title = data.title;
    if (data.startTime !== undefined) setData.startTime = data.startTime;
    if (data.endTime !== undefined) setData.endTime = data.endTime;
    if (data.location !== undefined) setData.location = data.location;
    if (data.capacity !== undefined) setData.capacity = data.capacity;
    if (data.order !== undefined) setData.order = data.order;
    if (data.status !== undefined) setData.status = data.status;

    const rows = await this.db
      .update(sessions)
      .set(setData)
      .where(eq(sessions.id, id))
      .returning();

    return rows[0] ? this.mapSession(rows[0]) : null;
  }

  async deleteSession(id: string): Promise<void> {
    await this.db.delete(sessions).where(eq(sessions.id, id));
  }

  async countSessionsByEventId(eventId: string): Promise<number> {
    const [{ value }] = await this.db
      .select({ value: count() })
      .from(sessions)
      .where(eq(sessions.eventId, eventId));
    return value;
  }

  async deleteSessionsByEventId(eventId: string): Promise<void> {
    await this.db.delete(sessions).where(eq(sessions.eventId, eventId));
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  private mapEvent(row: typeof events.$inferSelect): IEvent {
    return {
      id: row.id,
      title: row.title,
      description: row.description,
      type: row.type as IEvent['type'],
      status: row.status as IEvent['status'],
      visibility: row.visibility as IEvent['visibility'],
      location: row.location,
      contactPerson: row.contactPerson,
      imageUrl: row.imageUrl ?? null,
      maxParticipants: row.maxParticipants ?? null,
      createdBy: row.createdById,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }

  private mapSession(row: typeof sessions.$inferSelect): ISession {
    return {
      id: row.id,
      title: row.title,
      startTime: row.startTime,
      endTime: row.endTime,
      location: row.location ?? null,
      capacity: row.capacity ?? null,
      order: row.order,
      status: row.status as ISession['status'],
      eventId: row.eventId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }
}
