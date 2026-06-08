import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/entities/auth_response.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/login_input.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/entities/update_profile_input.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';
import 'package:kegiatin/domain/enums/session_status.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';
import 'package:kegiatin/domain/enums/user_role.dart';

final tFixedDate = DateTime(2026, 1, 15, 10, 0, 0);
final tFixedDateUtc = tFixedDate.toUtc();

User tUser({String? id, String? email, String? displayName, UserRole? role}) => User(
  id: id ?? 'user-1',
  email: email ?? 'test@example.com',
  displayName: displayName ?? 'Test User',
  role: role ?? UserRole.member,
  npa: '12345',
  cabang: 'Kab. Bandung',
  photoUrl: null,
  emailVerified: true,
  createdAt: tFixedDate,
);

Event tEvent({
  String? id,
  String? title,
  EventStatus? status,
  EventType? type,
  String? createdBy,
  List<Session>? sessions,
}) => Event(
  id: id ?? 'event-1',
  title: title ?? 'Test Event',
  description: 'Test description',
  type: type ?? EventType.single,
  status: status ?? EventStatus.draft,
  visibility: EventVisibility.open,
  location: 'Test Location',
  contactPerson: '08123456789',
  imageUrl: null,
  maxParticipants: 100,
  createdBy: createdBy ?? 'user-1',
  sessions: sessions ?? [tSession()],
  createdAt: tFixedDate,
  updatedAt: tFixedDate,
);

Session tSession({
  String? id,
  String? eventId,
  String? title,
  DateTime? startTime,
  DateTime? endTime,
  SessionStatus? status,
}) => Session(
  id: id ?? 'session-1',
  eventId: eventId ?? 'event-1',
  title: title ?? 'Sesi 1',
  startTime: startTime ?? tFixedDate,
  endTime: endTime ?? (startTime ?? tFixedDate).add(const Duration(hours: 2)),
  location: 'Room A',
  order: 1,
  status: status ?? SessionStatus.scheduled,
  capacity: 50,
);

Rsvp tRsvp({String? id, String? userId, String? eventId, String? qrToken, RsvpStatus? status}) => Rsvp(
  id: id ?? 'rsvp-1',
  userId: userId ?? 'user-1',
  eventId: eventId ?? 'event-1',
  qrToken: qrToken ?? 'qr-token-1',
  status: status ?? RsvpStatus.confirmed,
  createdAt: tFixedDate,
);

Attendance tAttendance({
  String? id,
  String? userId,
  String? sessionId,
  AttendanceStatus? status,
  SyncStatus? syncStatus,
  UserSummary? user,
}) => Attendance(
  id: id ?? 'attendance-1',
  userId: userId ?? 'user-1',
  sessionId: sessionId ?? 'session-1',
  rsvpId: 'rsvp-1',
  status: status ?? AttendanceStatus.present,
  syncStatus: syncStatus ?? SyncStatus.synced,
  checkedInAt: tFixedDate,
  syncedAt: tFixedDate,
  createdAt: tFixedDate,
  user: user,
);

AuthResponse tAuthResponse({User? user}) =>
    AuthResponse(user: user ?? tUser(), accessToken: 'access-token', refreshToken: 'refresh-token');

UserSummary tUserSummary({String? id}) => UserSummary(
  id: id ?? 'user-1',
  displayName: 'Test User',
  npa: '12345',
  cabang: 'Kab. Bandung',
  photoUrl: null,
);

RsvpWithUser tRsvpWithUser({String? id, String? userId, String? eventId, RsvpStatus? status}) =>
    RsvpWithUser(
      id: id ?? 'rsvp-1',
      userId: userId ?? 'user-1',
      eventId: eventId ?? 'event-1',
      qrToken: 'qr-token-1',
      status: status ?? RsvpStatus.confirmed,
      createdAt: tFixedDate,
      user: tUserSummary(),
    );

ArchiveItem tArchiveItem({String? id, ArchiveType? type}) => ArchiveItem(
  id: id ?? 'archive-1',
  sessionId: 'session-1',
  title: 'Test Archive',
  type: type ?? ArchiveType.material,
  fileUrl: 'https://example.com/file.pdf',
  createdAt: tFixedDate,
);

ActivityRecord tActivityRecord({Event? event}) => ActivityRecord(
  event: event ?? tEvent(),
  attendancePerSession: [
    SessionAttendance(
      session: tSession(),
      status: AttendanceStatus.present,
      checkedInAt: tFixedDate,
    ),
  ],
);

ProcessedImage tProcessedImage({String? filePath}) => ProcessedImage(
  filePath: filePath ?? '/tmp/test.jpg',
  enhancementMode: 'auto',
  fileSize: 1024,
  isDocumentScan: false,
);

LoginInput tLoginInput() => const LoginInput(email: 'test@example.com', password: 'password123');

RegisterInput tRegisterInput() => const RegisterInput(
  email: 'test@example.com',
  password: 'password123',
  displayName: 'Test User',
  userType: 'ANGGOTA',
  npa: '12345',
  cabang: 'Kab. Bandung',
);
CreateEventInput tCreateEventInput({List<SessionInput>? sessions}) => CreateEventInput(
  title: 'Test Event',
  description: 'Test description',
  type: EventType.single,
  visibility: EventVisibility.open,
  location: 'Test Location',
  contactPerson: '08123456789',
  maxParticipants: 100,
  sessions: sessions ?? [tSessionInput()],
);

UpdateEventInput tUpdateEventInput() =>
    const UpdateEventInput(title: 'Updated Event', description: 'Updated description');


SessionInput tSessionInput() => SessionInput(
  title: 'Sesi 1',
  startTime: tFixedDate,
  endTime: tFixedDate.add(const Duration(hours: 2)),
  location: 'Room A',
  capacity: 50,
);

UpdateProfileInput tUpdateProfileInput() => const UpdateProfileInput(displayName: 'Updated Name');

PaginatedResult<T> tPaginatedResult<T>(
  List<T> data, {
  int total = 1,
  int page = 1,
  int limit = 10,
}) => PaginatedResult<T>(data: data, total: total, page: page, limit: limit);

User tAdminUser() => tUser(role: UserRole.admin, displayName: 'Admin Test', email: 'admin@test.com');
User tMemberUser() => tUser(role: UserRole.member, displayName: 'Member Test', email: 'member@test.com');

List<Event> tEventList() => [
  tEvent(id: 'event-1', title: 'Kajian Rutin A', status: EventStatus.published),
  tEvent(id: 'event-2', title: 'Kajian Rutin B', status: EventStatus.draft),
  tEvent(id: 'event-3', title: 'Seminar Pemuda', status: EventStatus.ongoing),
  tEvent(id: 'event-4', title: 'Event Selesai', status: EventStatus.completed),
];

