import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/data/models/activity_record_model.dart';
import 'package:kegiatin/data/models/archive_model.dart';
import 'package:kegiatin/data/models/attendance_model.dart';
import 'package:kegiatin/data/models/event_model.dart';
import 'package:kegiatin/data/models/rsvp_model.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/entities/login_input.dart';
import 'package:kegiatin/domain/entities/update_profile_input.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';
import 'package:kegiatin/domain/enums/user_role.dart';
import 'package:kegiatin/domain/usecases/attendance/record_attendance_usecase.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

void registerUseCaseFallbackValues() {
  registerFallbackValue(
    const CreateEventInput(
      title: '',
      description: '',
      type: EventType.single,
      visibility: EventVisibility.open,
      location: '',
      contactPerson: '',
      sessions: [],
    ),
  );
  registerFallbackValue(
    const RegisterInput(email: '', password: '', displayName: '', userType: ''),
  );
  registerFallbackValue(const UpdateEventInput());
  registerFallbackValue(
    SessionInput(title: '', startTime: DateTime(2020), endTime: DateTime(2020)),
  );
  registerFallbackValue(const UpdateProfileInput());
  registerFallbackValue(Uint8List(0));
  registerFallbackValue(EnhancementMode.auto);
  registerFallbackValue(ArchiveType.material);
  registerFallbackValue(const LoginInput(email: '', password: ''));
  registerFallbackValue(const RecordAttendanceParams(qrToken: '', sessionId: ''));
  registerFallbackValue(NoInput.instance);
}

void registerRepoFallbackValues() {
  registerFallbackValue(
    EventModel(
      id: '',
      title: '',
      description: '',
      type: EventType.single,
      status: EventStatus.draft,
      visibility: EventVisibility.open,
      location: '',
      contactPerson: '',
      imageUrl: null,
      maxParticipants: null,
      createdBy: '',
      sessions: const [],
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    ),
  );
  registerFallbackValue(<EventModel>[]);
  registerFallbackValue(
    UserModel(
      id: '',
      email: '',
      displayName: '',
      role: UserRole.member,
      npa: null,
      cabang: null,
      photoUrl: null,
      emailVerified: false,
      createdAt: DateTime(2020),
    ),
  );
  registerFallbackValue(
    RsvpModel(
      id: '',
      userId: '',
      eventId: '',
      qrToken: '',
      status: RsvpStatus.confirmed,
      createdAt: DateTime(2020),
    ),
  );
  registerFallbackValue(<RsvpModel>[]);
  registerFallbackValue(
    ArchiveModel(
      id: '',
      sessionId: '',
      title: '',
      type: ArchiveType.material,
      fileUrl: '',
      createdAt: DateTime(2020),
    ),
  );
  registerFallbackValue(<ArchiveModel>[]);
  registerFallbackValue(
    AttendanceModel(
      id: '',
      userId: '',
      sessionId: '',
      rsvpId: '',
      status: AttendanceStatus.present,
      syncStatus: SyncStatus.pending,
      checkedInAt: DateTime(2020),
      syncedAt: null,
      createdAt: DateTime(2020),
    ),
  );
  registerFallbackValue(<AttendanceModel>[]);
  registerFallbackValue(
    ActivityRecordModel(
      event: EventModel(
        id: '',
        title: '',
        description: '',
        type: EventType.single,
        status: EventStatus.draft,
        visibility: EventVisibility.open,
        location: '',
        contactPerson: '',
        imageUrl: null,
        maxParticipants: null,
        createdBy: '',
        sessions: const [],
        createdAt: DateTime(2020),
        updatedAt: DateTime(2020),
      ),
      attendancePerSession: const [],
    ),
  );
  registerFallbackValue(<ActivityRecordModel>[]);
  registerFallbackValue(SyncStatus.pending);
  registerFallbackValue(AttendanceStatus.present);
}
