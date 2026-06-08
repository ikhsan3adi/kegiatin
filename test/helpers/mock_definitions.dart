import 'package:mocktail/mocktail.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/auth_local_datasource.dart';

import 'package:kegiatin/data/datasources/local/archive_local_datasource.dart';
import 'package:kegiatin/data/datasources/local/attendance_local_datasource.dart';
import 'package:kegiatin/data/datasources/local/event_local_datasource.dart';
import 'package:kegiatin/data/datasources/local/history_local_datasource.dart';
import 'package:kegiatin/data/datasources/local/rsvp_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/archive_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/attendance_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/event_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/history_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/profile_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/rsvp_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/session_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/uploads_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/user_remote_datasource.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/repositories/attendance_repository.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';
import 'package:kegiatin/domain/repositories/session_repository.dart';
import 'package:kegiatin/domain/repositories/archive_repository.dart';
import 'package:kegiatin/domain/repositories/profile_repository.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:kegiatin/domain/repositories/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockEventRepository extends Mock implements EventRepository {}

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class MockRsvpRepository extends Mock implements RsvpRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockArchiveRepository extends Mock implements ArchiveRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPcdRepository extends Mock implements PcdRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockEventRemoteDataSource extends Mock implements EventRemoteDataSource {}

class MockEventLocalDataSource extends Mock implements EventLocalDataSource {}

class MockAttendanceRemoteDataSource extends Mock implements AttendanceRemoteDataSource {}

class MockAttendanceLocalDataSource extends Mock implements AttendanceLocalDataSource {}

class MockRsvpRemoteDataSource extends Mock implements RsvpRemoteDataSource {}

class MockRsvpLocalDataSource extends Mock implements RsvpLocalDataSource {}

class MockSessionRemoteDataSource extends Mock implements SessionRemoteDataSource {}

class MockArchiveRemoteDataSource extends Mock implements ArchiveRemoteDataSource {}

class MockArchiveLocalDataSource extends Mock implements ArchiveLocalDataSource {}

class MockUploadsRemoteDataSource extends Mock implements UploadsRemoteDataSource {}

class MockProfileRemoteDataSource extends Mock implements ProfileRemoteDataSource {}

class MockHistoryRemoteDataSource extends Mock implements HistoryRemoteDataSource {}

class MockHistoryLocalDataSource extends Mock implements HistoryLocalDataSource {}

class MockUserRemoteDataSource extends Mock implements UserRemoteDataSource {}

class MockBox<T> extends Mock implements Box<T> {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockGoRouter extends Mock implements GoRouter {}

