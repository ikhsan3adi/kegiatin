import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IEventRepository } from '../domain/event.repository';
import {
  ICreateEventData,
  ICreateSessionData,
  IEvent,
  IEventFilter,
  ISession,
} from '../domain/event.types';
import { EventEntity } from '../entities/event.entity';
import { SessionEntity } from '../entities/session.entity';

@Injectable()
export class MongooseEventRepository implements IEventRepository {
  constructor(
    @InjectModel(EventEntity.name) private readonly eventModel: Model<EventEntity>,
    @InjectModel(SessionEntity.name) private readonly sessionModel: Model<SessionEntity>,
  ) {}

  private mapEvent(doc: any): IEvent {
    if (!doc) return doc;
    const { _id, ...rest } = doc;
    return {
      ...rest,
      id: _id.toString(),
      createdBy: rest.createdBy?.toString(),
    } as IEvent;
  }

  private mapSession(doc: any): ISession {
    if (!doc) return doc;
    const { _id, ...rest } = doc;
    return {
      ...rest,
      id: _id.toString(),
      eventId: rest.eventId?.toString(),
    } as ISession;
  }

  // --- Event Methods ---

  async createEvent(data: ICreateEventData): Promise<IEvent> {
    const created = await this.eventModel.create(data);
    return this.mapEvent(created.toObject());
  }

  async findEventById(id: string): Promise<IEvent | null> {
    const event = await this.eventModel.findById(id).lean().exec();
    return event ? this.mapEvent(event) : null;
  }

  async findEvents(
    filter: IEventFilter,
  ): Promise<{ events: IEvent[]; total: number }> {
    const query: Record<string, any> = {};

    if (filter.status) {
      query.status = filter.status;
    } else if (filter.statusIn) {
      query.status = { $in: filter.statusIn };
    }
    if (filter.type) query.type = filter.type;
    if (filter.visibility) query.visibility = filter.visibility;
    if (filter.search) {
      query.title = { $regex: filter.search, $options: 'i' };
    }

    const skip = (filter.page - 1) * filter.limit;

    const [events, total] = await Promise.all([
      this.eventModel
        .find(query)
        .sort({ createdAt: -1 }) // Terbaru di atas
        .skip(skip)
        .limit(filter.limit)
        .lean()
        .exec(),
      this.eventModel.countDocuments(query).exec(),
    ]);

    return {
      events: events.map((e) => this.mapEvent(e)),
      total,
    };
  }

  async updateEvent(id: string, data: Partial<IEvent>): Promise<IEvent | null> {
    const updated = await this.eventModel
      .findByIdAndUpdate(id, { $set: data }, { new: true })
      .lean()
      .exec();
    return updated ? this.mapEvent(updated) : null;
  }

  async deleteEvent(id: string): Promise<void> {
    await this.eventModel.findByIdAndDelete(id).exec();
  }

  // --- Session Methods ---

  async createSession(data: ICreateSessionData): Promise<ISession> {
    const created = await this.sessionModel.create(data);
    return this.mapSession(created.toObject());
  }

  async findSessionById(id: string): Promise<ISession | null> {
    const session = await this.sessionModel.findById(id).lean().exec();
    return session ? this.mapSession(session) : null;
  }

  async findSessionsByEventId(eventId: string): Promise<ISession[]> {
    const sessions = await this.sessionModel
      .find({ eventId })
      .sort({ order: 1 }) // Urut berdasarkan sesi 1, sesi 2, dst
      .lean()
      .exec();
    return sessions.map((s) => this.mapSession(s));
  }

  async updateSession(
    id: string,
    data: Partial<ISession>,
  ): Promise<ISession | null> {
    const updated = await this.sessionModel
      .findByIdAndUpdate(id, { $set: data }, { new: true })
      .lean()
      .exec();
    return updated ? this.mapSession(updated) : null;
  }

  async deleteSession(id: string): Promise<void> {
    await this.sessionModel.findByIdAndDelete(id).exec();
  }

  async countSessionsByEventId(eventId: string): Promise<number> {
    return this.sessionModel.countDocuments({ eventId }).exec();
  }

  async deleteSessionsByEventId(eventId: string): Promise<void> {
    await this.sessionModel.deleteMany({ eventId }).exec();
  }
}
