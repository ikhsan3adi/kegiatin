import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { and, eq, inArray, ilike, count } from 'drizzle-orm';
import { DRIZZLE } from '../../database/drizzle.provider';
import type { DrizzleDB } from '../../database/drizzle.provider';
import {
  users,
  events,
  sessions,
  rsvps,
  attendances,
} from '../../database/schema';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ProfileHistoryQueryDto } from './dto/profile-history-query.dto';

@Injectable()
export class ProfileService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async getProfile(userId: string) {
    const [user] = await this.db
      .select({
        id: users.id,
        email: users.email,
        displayName: users.displayName,
        role: users.role,
        npa: users.npa,
        cabang: users.cabang,
        photoUrl: users.photoUrl,
        emailVerified: users.emailVerified,
        createdAt: users.createdAt,
      })
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);

    if (!user) throw new NotFoundException('User tidak ditemukan');
    return user;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const [existing] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);

    if (!existing) throw new NotFoundException('User tidak ditemukan');

    const updateData: Record<string, string> = {};
    if (dto.displayName !== undefined) updateData.displayName = dto.displayName;
    if (dto.cabang !== undefined) updateData.cabang = dto.cabang;
    if (dto.photoUrl !== undefined) updateData.photoUrl = dto.photoUrl;

    if (Object.keys(updateData).length > 0) {
      await this.db.update(users).set(updateData).where(eq(users.id, userId));
    }

    return this.getProfile(userId);
  }

  async getHistory(userId: string, query: ProfileHistoryQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const search = query.search;

    const rsvpRecords = await this.db
      .select({
        id: rsvps.id,
        eventId: rsvps.eventId,
        qrToken: rsvps.qrToken,
        status: rsvps.status,
        createdAt: rsvps.createdAt,
        eventTitle: events.title,
        eventDescription: events.description,
        eventType: events.type,
        eventStatus: events.status,
        eventVisibility: events.visibility,
        eventLocation: events.location,
        eventContactPerson: events.contactPerson,
        eventImageUrl: events.imageUrl,
        eventMaxParticipants: events.maxParticipants,
        eventCreatedAt: events.createdAt,
        eventUpdatedAt: events.updatedAt,
      })
      .from(rsvps)
      .innerJoin(events, eq(rsvps.eventId, events.id))
      .where(
        and(
          eq(rsvps.userId, userId),
          eq(rsvps.status, 'CONFIRMED'),
          search ? ilike(events.title, `%${search}%`) : undefined,
        ),
      )
      .orderBy(events.createdAt)
      .limit(limit)
      .offset((page - 1) * limit);

    const [{ total }] = await this.db
      .select({ total: count() })
      .from(rsvps)
      .innerJoin(events, eq(rsvps.eventId, events.id))
      .where(
        and(
          eq(rsvps.userId, userId),
          eq(rsvps.status, 'CONFIRMED'),
          search ? ilike(events.title, `%${search}%`) : undefined,
        ),
      );

    const eventIds = rsvpRecords.map((r) => r.eventId);

    const sessionList =
      eventIds.length > 0
        ? await this.db
            .select()
            .from(sessions)
            .where(inArray(sessions.eventId, eventIds))
            .orderBy(sessions.order)
        : [];

    const sessionIds = sessionList.map((s) => s.id);

    const attendanceList =
      sessionIds.length > 0
        ? await this.db
            .select()
            .from(attendances)
            .where(
              and(
                inArray(attendances.sessionId, sessionIds),
                eq(attendances.userId, userId),
              ),
            )
        : [];

    const attendanceBySession = new Map(
      attendanceList.map((a) => [a.sessionId, a]),
    );

    const data = rsvpRecords.map((r) => {
      const eventSessions = sessionList
        .filter((s) => s.eventId === r.eventId)
        .map((s) => {
          const att = attendanceBySession.get(s.id);
          return {
            session: {
              id: s.id,
              title: s.title,
              startTime: s.startTime,
              endTime: s.endTime,
              location: s.location,
              order: s.order,
              status: s.status,
              capacity: s.capacity,
            },
            status: att?.status ?? null,
            checkedInAt: att?.checkedInAt ?? null,
          };
        });

      return {
        event: {
          id: r.eventId,
          title: r.eventTitle,
          description: r.eventDescription,
          type: r.eventType,
          status: r.eventStatus,
          visibility: r.eventVisibility,
          location: r.eventLocation,
          contactPerson: r.eventContactPerson,
          imageUrl: r.eventImageUrl,
          maxParticipants: r.eventMaxParticipants,
          createdAt: r.eventCreatedAt,
          updatedAt: r.eventUpdatedAt,
          sessions: eventSessions.map((es) => es.session),
        },
        attendancePerSession: eventSessions.map((es) => ({
          session: es.session,
          status: es.status,
          checkedInAt: es.checkedInAt,
        })),
      };
    });

    return {
      data,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
