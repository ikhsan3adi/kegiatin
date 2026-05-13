import { randomBytes } from 'crypto';
import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { IEventRepository } from '../events/domain/event.repository';
import { IRsvpRepository } from './domain/rsvp.repository';
import { canCancelRsvp, canRsvp, isEventFull } from './domain/rsvp.rules';
import { IRsvp, IRsvpFilter, IRsvpWithUser } from './domain/rsvp.types';

@Injectable()
export class RsvpService {
  constructor(
    private readonly rsvpRepo: IRsvpRepository,
    private readonly eventRepo: IEventRepository,
  ) {}

  // ---------------------------------------------------------------------------
  // Create RSVP
  // ---------------------------------------------------------------------------

  async createRsvp(userId: string, eventId: string): Promise<IRsvp> {
    const event = await this.eventRepo.findEventById(eventId);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    if (!canRsvp(event.status)) {
      throw new BadRequestException(
        'Event tidak menerima RSVP (hanya event PUBLISHED)',
      );
    }

    const existing = await this.rsvpRepo.findByUserAndEvent(userId, eventId);
    if (existing) {
      throw new ConflictException('Sudah terdaftar di event ini');
    }

    const currentCount = await this.rsvpRepo.countConfirmedByEventId(eventId);
    if (isEventFull(currentCount, event.maxParticipants)) {
      throw new BadRequestException('Kuota peserta event sudah penuh');
    }

    const qrToken = this.generateQrToken(eventId, userId);

    return this.rsvpRepo.create({ userId, eventId, qrToken });
  }

  // ---------------------------------------------------------------------------
  // List RSVPs by Event (Admin)
  // ---------------------------------------------------------------------------

  async listByEvent(
    eventId: string,
    filter: IRsvpFilter,
  ): Promise<{ data: IRsvpWithUser[]; meta: object }> {
    const event = await this.eventRepo.findEventById(eventId);
    if (!event) throw new NotFoundException('Event tidak ditemukan');

    const { rsvps, total } = await this.rsvpRepo.findByEventId(eventId, filter);

    return {
      data: rsvps,
      meta: {
        page: filter.page,
        limit: filter.limit,
        total,
        totalPages: Math.ceil(total / filter.limit),
      },
    };
  }

  // ---------------------------------------------------------------------------
  // List My RSVPs
  // ---------------------------------------------------------------------------

  async listMyRsvps(
    userId: string,
    filter: IRsvpFilter,
  ): Promise<{ data: IRsvp[]; meta: object }> {
    const { rsvps, total } = await this.rsvpRepo.findByUserId(userId, filter);

    return {
      data: rsvps,
      meta: {
        page: filter.page,
        limit: filter.limit,
        total,
        totalPages: Math.ceil(total / filter.limit),
      },
    };
  }

  // ---------------------------------------------------------------------------
  // Cancel RSVP (hard-delete)
  // ---------------------------------------------------------------------------

  async cancelRsvp(rsvpId: string, userId: string): Promise<void> {
    const rsvp = await this.rsvpRepo.findById(rsvpId);
    if (!rsvp) throw new NotFoundException('RSVP tidak ditemukan');

    if (rsvp.userId !== userId) {
      throw new ForbiddenException('Tidak memiliki akses ke RSVP ini');
    }

    if (!canCancelRsvp(rsvp.status)) {
      throw new BadRequestException('RSVP tidak dapat dibatalkan');
    }

    await this.rsvpRepo.delete(rsvpId);
  }

  // ---------------------------------------------------------------------------
  // Get QR Token
  // ---------------------------------------------------------------------------

  async getQrToken(
    rsvpId: string,
    userId: string,
  ): Promise<{ qrToken: string }> {
    const rsvp = await this.rsvpRepo.findById(rsvpId);
    if (!rsvp) throw new NotFoundException('RSVP tidak ditemukan');

    if (rsvp.userId !== userId) {
      throw new ForbiddenException('Tidak memiliki akses ke RSVP ini');
    }

    return { qrToken: rsvp.qrToken };
  }

  // ---------------------------------------------------------------------------
  // QR Token Generation (structured format)
  // ---------------------------------------------------------------------------

  /**
   * Generates a structured QR token: base64url(eventId:userId:randomHex).
   * The embedded context allows offline validation without a DB lookup.
   */
  private generateQrToken(eventId: string, userId: string): string {
    const random = randomBytes(16).toString('hex');
    const payload = `${eventId}:${userId}:${random}`;
    return Buffer.from(payload).toString('base64url');
  }
}
