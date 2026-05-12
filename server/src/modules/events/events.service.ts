import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { IEventRepository } from './domain/event.repository';
import {
  EventStatus,
  EventType,
  IEvent,
  IEventResponse,
  ISession,
  SessionStatus,
} from './domain/event.types';
import { CreateEventDto } from './dto/create-event.dto';
import { CreateSessionDto } from './dto/create-session.dto';
import { EventQueryDto } from './dto/event-query.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { UpdateSessionStatusDto } from './dto/update-session-status.dto';
import { UpdateSessionDto } from './dto/update-session.dto';

@Injectable()
export class EventsService {
  constructor(private readonly eventRepo: IEventRepository) {}

  // ---------------------------------------------------------------------------
  // EVENTS
  // ---------------------------------------------------------------------------

  async create(userId: string, dto: CreateEventDto): Promise<IEventResponse> {
    if (dto.type === EventType.SINGLE && dto.sessions.length !== 1) {
      throw new BadRequestException('Single event harus memiliki tepat 1 sesi');
    }

    const event = await this.eventRepo.createEvent({
      title: dto.title,
      description: dto.description,
      type: dto.type,
      visibility: dto.visibility,
      location: dto.location,
      contactPerson: dto.contactPerson,
      imageUrl: dto.imageUrl,
      maxParticipants: dto.maxParticipants,
      createdBy: userId,
    });

    const sessions: ISession[] = [];
    for (let i = 0; i < dto.sessions.length; i++) {
      const s = dto.sessions[i];
      const session = await this.eventRepo.createSession({
        ...s,
        startTime: new Date(s.startTime),
        endTime: new Date(s.endTime),
        order: i + 1,
        eventId: event.id,
      });
      sessions.push(session);
    }

    return { ...event, sessions };
  }

  async findAll(query: EventQueryDto, userRole: string) {
    const MEMBER_VISIBLE: EventStatus[] = [
      EventStatus.PUBLISHED,
      EventStatus.ONGOING,
      EventStatus.COMPLETED,
    ];

    let effectiveStatus = query.status;
    let effectiveStatusIn: EventStatus[] | undefined;

    if (userRole !== 'ADMIN') {
      if (query.status) {
        if (!MEMBER_VISIBLE.includes(query.status)) {
          return {
            data: [] as IEventResponse[],
            meta: {
              page: query.page,
              limit: query.limit,
              total: 0,
              totalPages: 0,
            },
          };
        }
      } else {
        effectiveStatus = undefined;
        effectiveStatusIn = MEMBER_VISIBLE;
      }
    }

    const { events, total } = await this.eventRepo.findEvents({
      page: query.page,
      limit: query.limit,
      status: effectiveStatus,
      statusIn: effectiveStatusIn,
      type: query.type,
      visibility: query.visibility,
      search: query.search,
    });

    const data: IEventResponse[] = await Promise.all(
      events.map(async (event) => {
        const sessions = await this.eventRepo.findSessionsByEventId(event.id);
        return { ...event, sessions };
      }),
    );

    const totalPages = Math.ceil(total / query.limit);

    return {
      data,
      meta: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages,
      },
    };
  }

  async findOne(id: string): Promise<IEventResponse> {
    const event = await this.eventRepo.findEventById(id);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    const sessions = await this.eventRepo.findSessionsByEventId(id);
    return { ...event, sessions };
  }

  async update(id: string, dto: UpdateEventDto): Promise<IEventResponse> {
    const existing = await this.eventRepo.findEventById(id);
    if (!existing) throw new NotFoundException('Event tidak ditemukan');

    if (
      existing.status !== EventStatus.DRAFT &&
      existing.status !== EventStatus.PUBLISHED
    ) {
      throw new BadRequestException(
        'Hanya event berstatus DRAFT atau PUBLISHED yang dapat diedit',
      );
    }

    const event = await this.eventRepo.updateEvent(id, dto as Partial<IEvent>);
    const sessions = await this.eventRepo.findSessionsByEventId(id);
    return { ...event!, sessions };
  }

  async delete(id: string): Promise<void> {
    const existing = await this.eventRepo.findEventById(id);
    if (!existing) throw new NotFoundException('Event tidak ditemukan');

    if (existing.status !== EventStatus.DRAFT) {
      throw new BadRequestException('Hanya event DRAFT yang dapat dihapus');
    }

    await this.eventRepo.deleteEvent(id);
    await this.eventRepo.deleteSessionsByEventId(id);
  }

  async publish(id: string): Promise<void> {
    const event = await this.eventRepo.findEventById(id);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    if (event.status !== EventStatus.DRAFT) {
      throw new BadRequestException('Hanya event DRAFT yang dapat di-publish');
    }

    const sessionCount = await this.eventRepo.countSessionsByEventId(id);
    if (sessionCount < 1) {
      throw new BadRequestException(
        'Event harus memiliki minimal 1 sesi untuk dapat di-publish',
      );
    }

    await this.eventRepo.updateEvent(id, { status: EventStatus.PUBLISHED });
  }

  async cancel(id: string): Promise<void> {
    const event = await this.eventRepo.findEventById(id);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    if (
      event.status === EventStatus.COMPLETED ||
      event.status === EventStatus.CANCELLED
    ) {
      throw new BadRequestException('Event sudah selesai atau dibatalkan');
    }

    await this.eventRepo.updateEvent(id, { status: EventStatus.CANCELLED });
  }

  async start(id: string): Promise<void> {
    const event = await this.eventRepo.findEventById(id);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    if (event.status !== EventStatus.PUBLISHED) {
      throw new BadRequestException('Hanya event PUBLISHED yang dapat dimulai');
    }

    await this.eventRepo.updateEvent(id, { status: EventStatus.ONGOING });
  }

  async complete(id: string): Promise<void> {
    const event = await this.eventRepo.findEventById(id);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    if (event.status !== EventStatus.ONGOING) {
      throw new BadRequestException(
        'Hanya event ONGOING yang dapat diselesaikan',
      );
    }

    await this.eventRepo.updateEvent(id, { status: EventStatus.COMPLETED });
  }

  // ---------------------------------------------------------------------------
  // SESSIONS
  // ---------------------------------------------------------------------------

  async addSession(eventId: string, dto: CreateSessionDto): Promise<ISession> {
    const event = await this.eventRepo.findEventById(eventId);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    if (event.type === EventType.SINGLE) {
      throw new BadRequestException('Tidak bisa menambah sesi ke Single Event');
    }

    const currentSessionsCount =
      await this.eventRepo.countSessionsByEventId(eventId);
    return this.eventRepo.createSession({
      ...dto,
      startTime: new Date(dto.startTime),
      endTime: new Date(dto.endTime),
      order: currentSessionsCount + 1,
      eventId,
    });
  }

  async updateSession(
    sessionId: string,
    dto: UpdateSessionDto,
  ): Promise<ISession> {
    const session = await this.eventRepo.findSessionById(sessionId);
    if (!session) throw new NotFoundException('Sesi tidak ditemukan');

    if (session.status === SessionStatus.COMPLETED) {
      throw new BadRequestException(
        'Sesi yang sudah selesai tidak dapat diedit',
      );
    }

    const data: any = { ...dto };
    if (dto.startTime) data.startTime = new Date(dto.startTime);
    if (dto.endTime) data.endTime = new Date(dto.endTime);

    const updated = await this.eventRepo.updateSession(sessionId, data);
    return updated!;
  }

  async deleteSession(sessionId: string): Promise<void> {
    const session = await this.eventRepo.findSessionById(sessionId);
    if (!session) throw new NotFoundException('Sesi tidak ditemukan');

    const event = await this.eventRepo.findEventById(session.eventId);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    if (event.type === EventType.SINGLE) {
      throw new BadRequestException(
        'Tidak bisa menghapus sesi pada Single Event',
      );
    }

    if (
      event.status !== EventStatus.DRAFT &&
      event.status !== EventStatus.PUBLISHED
    ) {
      throw new BadRequestException(
        'Sesi hanya dapat dihapus jika event berstatus DRAFT atau PUBLISHED',
      );
    }

    await this.eventRepo.deleteSession(sessionId);

    // Re-order remaining sessions to ensure sequential ordering (1, 2, 3...)
    const remaining = await this.eventRepo.findSessionsByEventId(event.id);
    for (let i = 0; i < remaining.length; i++) {
      if (remaining[i].order !== i + 1) {
        await this.eventRepo.updateSession(remaining[i].id, { order: i + 1 });
      }
    }
  }

  async updateSessionStatus(
    sessionId: string,
    dto: UpdateSessionStatusDto,
  ): Promise<ISession> {
    const session = await this.eventRepo.findSessionById(sessionId);
    if (!session) throw new NotFoundException('Sesi tidak ditemukan');

    const newStatus = dto.status;
    const oldStatus = session.status;

    if (oldStatus === SessionStatus.COMPLETED) {
      throw new BadRequestException(
        'Sesi sudah COMPLETED, status tidak dapat diubah lagi',
      );
    }

    if (newStatus === SessionStatus.ONGOING) {
      if (oldStatus !== SessionStatus.SCHEDULED) {
        throw new BadRequestException(
          'Hanya sesi SCHEDULED yang dapat diubah ke ONGOING',
        );
      }
    } else if (newStatus === SessionStatus.COMPLETED) {
      if (oldStatus !== SessionStatus.ONGOING) {
        throw new BadRequestException(
          'Hanya sesi ONGOING yang dapat diubah ke COMPLETED',
        );
      }
    } else if (newStatus === SessionStatus.SCHEDULED) {
      if (oldStatus !== SessionStatus.POSTPONED) {
        throw new BadRequestException(
          'Hanya sesi POSTPONED yang dapat diubah ke SCHEDULED',
        );
      }
    }

    const updated = await this.eventRepo.updateSession(sessionId, {
      status: newStatus,
    });
    return updated!;
  }
}
