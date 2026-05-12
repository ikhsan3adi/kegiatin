import { BadRequestException, ConflictException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { IEventRepository } from '../events/domain/event.repository';
import {
  EventStatus,
  EventType,
  EventVisibility,
  SessionStatus,
} from '../events/domain/event.types';
import { IRsvpRepository } from '../rsvp/domain/rsvp.repository';
import { RsvpStatus } from '../rsvp/domain/rsvp.types';
import { AttendanceService } from './attendance.service';
import { AttendanceDuplicateError } from './domain/attendance.errors';
import { IAttendanceRepository } from './domain/attendance.repository';
import {
  AttendanceStatus,
  AttendanceSyncStatus,
} from './domain/attendance.types';

describe('AttendanceService', () => {
  let service: AttendanceService;
  let attendanceRepo: jest.Mocked<IAttendanceRepository>;
  let rsvpRepo: jest.Mocked<IRsvpRepository>;
  let eventRepo: jest.Mocked<IEventRepository>;

  const sessionId = '11111111-1111-7111-8111-111111111111';
  const eventId = '22222222-2222-7222-8222-222222222222';
  const userId = '33333333-3333-7333-8333-333333333333';
  const rsvpId = '44444444-4444-7444-8444-444444444444';
  const qrToken = 'test-qr-token-secret';

  const session = {
    id: sessionId,
    title: 'Sesi 1',
    startTime: new Date('2026-06-01T08:00:00.000Z'),
    endTime: new Date('2026-06-01T10:00:00.000Z'),
    location: null,
    capacity: null,
    order: 1,
    status: SessionStatus.SCHEDULED,
    eventId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const event = {
    id: eventId,
    title: 'Event',
    description: '',
    type: EventType.SINGLE,
    status: EventStatus.PUBLISHED,
    visibility: EventVisibility.OPEN,
    location: '',
    contactPerson: '',
    imageUrl: null,
    maxParticipants: 100,
    createdBy: userId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const rsvp = {
    id: rsvpId,
    userId,
    eventId,
    qrToken,
    status: RsvpStatus.CONFIRMED,
    createdAt: new Date(),
  };

  beforeEach(async () => {
    attendanceRepo = {
      create: jest.fn(),
      findByUserAndSession: jest.fn(),
      findBySessionId: jest.fn(),
    };

    rsvpRepo = {
      findByQrToken: jest.fn(),
    } as unknown as jest.Mocked<IRsvpRepository>;

    eventRepo = {
      findSessionById: jest.fn(),
      findEventById: jest.fn(),
      findUserBriefById: jest.fn(),
    } as unknown as jest.Mocked<IEventRepository>;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AttendanceService,
        { provide: IAttendanceRepository, useValue: attendanceRepo },
        { provide: IRsvpRepository, useValue: rsvpRepo },
        { provide: IEventRepository, useValue: eventRepo },
      ],
    }).compile();

    service = module.get(AttendanceService);
  });

  it('scan creates attendance when valid', async () => {
    eventRepo.findSessionById.mockResolvedValue(session);
    rsvpRepo.findByQrToken.mockResolvedValue(rsvp);
    eventRepo.findEventById.mockResolvedValue(event);
    attendanceRepo.findByUserAndSession.mockResolvedValue(null);

    const created = {
      id: '55555555-5555-7555-8555-555555555555',
      userId,
      sessionId,
      rsvpId,
      status: AttendanceStatus.PRESENT,
      syncStatus: AttendanceSyncStatus.SYNCED,
      checkedInAt: new Date(),
      syncedAt: new Date(),
      createdAt: new Date(),
    };
    attendanceRepo.create.mockResolvedValue(created);

    const result = await service.scan({ qrToken, sessionId });

    expect(result).toBe(created);
    expect(attendanceRepo.create.mock.calls.length).toBe(1);
    const createArg = attendanceRepo.create.mock.calls[0]?.[0];
    expect(createArg).toEqual(
      expect.objectContaining({
        userId,
        sessionId,
        rsvpId,
        syncStatus: AttendanceSyncStatus.SYNCED,
      }),
    );
  });

  it('scan throws Conflict when already checked in', async () => {
    eventRepo.findSessionById.mockResolvedValue(session);
    rsvpRepo.findByQrToken.mockResolvedValue(rsvp);
    eventRepo.findEventById.mockResolvedValue(event);
    attendanceRepo.findByUserAndSession.mockResolvedValue({
      id: 'x',
      userId,
      sessionId,
      rsvpId,
      status: AttendanceStatus.PRESENT,
      syncStatus: AttendanceSyncStatus.SYNCED,
      checkedInAt: new Date(),
      syncedAt: new Date(),
      createdAt: new Date(),
    });

    await expect(service.scan({ qrToken, sessionId })).rejects.toBeInstanceOf(
      ConflictException,
    );
    expect(attendanceRepo.create.mock.calls.length).toBe(0);
  });

  it('scan throws BadRequest when QR unknown', async () => {
    eventRepo.findSessionById.mockResolvedValue(session);
    rsvpRepo.findByQrToken.mockResolvedValue(null);

    await expect(service.scan({ qrToken, sessionId })).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });

  it('sync returns INVALID for bad token', async () => {
    eventRepo.findSessionById.mockResolvedValue(session);
    rsvpRepo.findByQrToken.mockResolvedValue(null);

    const out = await service.sync({
      records: [
        {
          localId: 'local-1',
          qrToken: 'bad',
          sessionId,
          checkedInAt: '2026-06-01T08:30:00.000Z',
        },
      ],
    });

    expect(out.results[0].status).toBe('INVALID');
    expect(out.summary.invalid).toBe(1);
  });

  it('sync returns CONFLICT when attendance exists', async () => {
    eventRepo.findSessionById.mockResolvedValue(session);
    rsvpRepo.findByQrToken.mockResolvedValue(rsvp);
    eventRepo.findEventById.mockResolvedValue(event);
    attendanceRepo.findByUserAndSession.mockResolvedValue({
      id: 'existing-id',
      userId,
      sessionId,
      rsvpId,
      status: AttendanceStatus.PRESENT,
      syncStatus: AttendanceSyncStatus.SYNCED,
      checkedInAt: new Date(),
      syncedAt: new Date(),
      createdAt: new Date(),
    });

    const out = await service.sync({
      records: [
        {
          localId: 'l1',
          qrToken,
          sessionId,
          checkedInAt: '2026-06-01T08:30:00.000Z',
        },
      ],
    });

    expect(out.results[0].status).toBe('CONFLICT');
    expect(out.results[0].serverId).toBe('existing-id');
    expect(attendanceRepo.create.mock.calls.length).toBe(0);
  });

  it('sync returns CONFLICT on duplicate insert race', async () => {
    eventRepo.findSessionById.mockResolvedValue(session);
    rsvpRepo.findByQrToken.mockResolvedValue(rsvp);
    eventRepo.findEventById.mockResolvedValue(event);
    attendanceRepo.findByUserAndSession
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({
        id: 'race-id',
        userId,
        sessionId,
        rsvpId,
        status: AttendanceStatus.PRESENT,
        syncStatus: AttendanceSyncStatus.SYNCED,
        checkedInAt: new Date(),
        syncedAt: new Date(),
        createdAt: new Date(),
      });
    attendanceRepo.create.mockRejectedValue(new AttendanceDuplicateError());

    const out = await service.sync({
      records: [
        {
          localId: 'l1',
          qrToken,
          sessionId,
          checkedInAt: '2026-06-01T08:30:00.000Z',
        },
      ],
    });

    expect(out.results[0].status).toBe('CONFLICT');
    expect(out.results[0].serverId).toBe('race-id');
  });
});
