import { faker } from '@faker-js/faker';
import { UserType } from '../../../src/modules/auth/dto/register.dto';
import {
  EventType,
  EventVisibility,
} from '../../../src/modules/events/domain/event.types';

/**
 * Matches RegisterDto: email, password (min 8), displayName, userType (ANGGOTA|UMUM).
 * Optional: npa, cabang.
 */
export function fakeRegisterDto(index: number) {
  const suffix = `${Date.now()}-${index}`;
  return {
    email: `stress-${suffix}@test.local`,
    password: 'StressTest123!',
    displayName: faker.person.fullName(),
    userType: UserType.UMUM,
  };
}

/**
 * Matches CreateEventDto: title (required), type, visibility, location (required!),
 * sessions (ArrayMinSize(1)), optional: description, contactPerson, imageUrl, maxParticipants.
 */
export function fakeCreateEventDto(opts?: {
  type?: EventType;
  sessionCount?: number;
  maxParticipants?: number;
}) {
  const type = opts?.type ?? EventType.SINGLE;
  const count = type === EventType.SINGLE ? 1 : (opts?.sessionCount ?? 3);

  const sessions = Array.from({ length: count }, (_, i) => {
    const start = faker.date.future({ years: 1 });
    const end = new Date(start.getTime() + 3_600_000);
    return {
      title: `Sesi ${i + 1}: ${faker.lorem.words(3)}`,
      startTime: start.toISOString(),
      endTime: end.toISOString(),
      location: faker.location.city(),
    };
  });

  return {
    title: faker.lorem.sentence({ min: 3, max: 8 }),
    description: faker.lorem.paragraphs(2),
    type,
    visibility: EventVisibility.OPEN,
    location: faker.location.streetAddress(),
    contactPerson: `${faker.person.fullName()} ${faker.phone.number()}`,
    ...(opts?.maxParticipants != null
      ? { maxParticipants: opts.maxParticipants }
      : {}),
    sessions,
  };
}

/**
 * Build sync batch payload matching SyncAttendanceBatchDto.
 */
export function fakeSyncBatch(
  entries: Array<{ qrToken: string; sessionId: string }>,
) {
  return {
    records: entries.map(({ qrToken, sessionId }) => ({
      localId: `local-${faker.string.uuid()}`,
      qrToken,
      sessionId,
      checkedInAt: faker.date.recent().toISOString(),
    })),
  };
}
