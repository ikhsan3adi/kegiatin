import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/models/activity_record_model.dart';
import 'package:kegiatin/data/models/event_model.dart';
import 'package:kegiatin/data/models/session_model.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:kegiatin/data/repositories/profile_repository_impl.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockProfileRemoteDataSource profileRemoteDataSource;
  late MockHistoryRemoteDataSource historyRemoteDataSource;
  late MockHistoryLocalDataSource historyLocalDataSource;
  late MockAuthLocalDataSource authLocalDataSource;
  late MockNetworkInfo networkInfo;
  late ProfileRepositoryImpl repository;

  setUpAll(() {
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    profileRemoteDataSource = MockProfileRemoteDataSource();
    historyRemoteDataSource = MockHistoryRemoteDataSource();
    historyLocalDataSource = MockHistoryLocalDataSource();
    authLocalDataSource = MockAuthLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = ProfileRepositoryImpl(
      profileRemoteDataSource: profileRemoteDataSource,
      historyRemoteDataSource: historyRemoteDataSource,
      historyLocalDataSource: historyLocalDataSource,
      authLocalDataSource: authLocalDataSource,
      networkInfo: networkInfo,
    );
  });

  group('getProfile', () {
    test('returns cached user when offline + cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final user = tUser();
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
        npa: user.npa,
        cabang: user.cabang,
        photoUrl: user.photoUrl,
        emailVerified: user.emailVerified,
        createdAt: user.createdAt,
      );
      when(() => authLocalDataSource.getCachedUser()).thenAnswer((_) async => userModel);

      final result = await repository.getProfile();

      expect(result.isRight(), true);
    });

    test('returns NetworkFailure when offline + no cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => authLocalDataSource.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.getProfile();

      expect(result, const Left(NetworkFailure()));
    });

    test('returns remote + cache locally when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final user = tUser();
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
        npa: user.npa,
        cabang: user.cabang,
        photoUrl: user.photoUrl,
        emailVerified: user.emailVerified,
        createdAt: user.createdAt,
      );
      when(() => profileRemoteDataSource.getProfile()).thenAnswer((_) async => userModel);
      when(() => authLocalDataSource.saveUser(any())).thenAnswer((_) async {});

      final result = await repository.getProfile();

      expect(result.isRight(), true);
    });

    test('returns ServerFailure on remote exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => profileRemoteDataSource.getProfile()).thenThrow(Exception('Error'));

      final result = await repository.getProfile();

      expect(result.isLeft(), true);
    });
  });

  group('updateProfile', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateProfile(tUpdateProfileInput());

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(User) + syncs cache on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final user = tUser();
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        displayName: 'Updated Name',
        role: user.role,
        npa: user.npa,
        cabang: user.cabang,
        photoUrl: user.photoUrl,
        emailVerified: user.emailVerified,
        createdAt: user.createdAt,
      );
      when(() => profileRemoteDataSource.updateProfile(any())).thenAnswer((_) async => userModel);
      when(() => authLocalDataSource.saveUser(any())).thenAnswer((_) async {});

      final result = await repository.updateProfile(tUpdateProfileInput());

      expect(result.isRight(), true);
      verify(() => authLocalDataSource.saveUser(any())).called(1);
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => profileRemoteDataSource.updateProfile(any())).thenThrow(Exception('Error'));

      final result = await repository.updateProfile(tUpdateProfileInput());

      expect(result.isLeft(), true);
    });
  });

  group('getHistory', () {
    test('returns cached when not forceRefresh + cache exists', () async {
      when(
        () => historyLocalDataSource.getCachedHistory('p1_l20_'),
      ).thenAnswer((_) async => [tActivityRecordModel()]);

      final result = await repository.getHistory();

      expect(result.isRight(), true);
    });

    test('fetches remote + caches when online', () async {
      when(() => historyLocalDataSource.getCachedHistory('p1_l20_')).thenAnswer((_) async => []);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final models = [tActivityRecordModel()];
      when(
        () => historyRemoteDataSource.getHistory(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
        ),
      ).thenAnswer((_) async => models);
      when(() => historyLocalDataSource.cacheHistory(any(), any())).thenAnswer((_) async {});

      final result = await repository.getHistory();

      expect(result.isRight(), true);
    });

    test('falls back to cache on remote exception', () async {
      when(() => historyLocalDataSource.getCachedHistory('p1_l20_')).thenAnswer((_) async => []);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => historyRemoteDataSource.getHistory(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
        ),
      ).thenThrow(Exception('Error'));
      when(
        () => historyLocalDataSource.getCachedHistory(any()),
      ).thenAnswer((_) async => [tActivityRecordModel()]);

      final result = await repository.getHistory();

      expect(result.isRight(), true);
    });

    test('returns cached when offline + cache exists', () async {
      when(() => historyLocalDataSource.getCachedHistory('p1_l20_')).thenAnswer((_) async => []);
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => historyLocalDataSource.getCachedHistory(any()),
      ).thenAnswer((_) async => [tActivityRecordModel()]);

      final result = await repository.getHistory();

      expect(result.isRight(), true);
    });

    test('returns NetworkFailure when offline + no cache', () async {
      when(() => historyLocalDataSource.getCachedHistory('p1_l20_')).thenAnswer((_) async => []);
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => historyLocalDataSource.getCachedHistory(any())).thenAnswer((_) async => []);

      final result = await repository.getHistory();

      expect(result, const Left(NetworkFailure()));
    });
  });
}

ActivityRecordModel tActivityRecordModel() {
  final event = tEvent();
  final session = tSession();
  final eventModel = EventModel(
    id: event.id,
    title: event.title,
    description: event.description,
    type: event.type,
    status: event.status,
    visibility: event.visibility,
    location: event.location,
    contactPerson: event.contactPerson,
    imageUrl: event.imageUrl,
    maxParticipants: event.maxParticipants,
    createdBy: event.createdBy,
    sessions: [],
    createdAt: event.createdAt,
    updatedAt: event.updatedAt,
  );
  final sessionModel = SessionModel(
    id: session.id,
    eventId: session.eventId,
    title: session.title,
    startTime: session.startTime,
    endTime: session.endTime,
    location: session.location,
    order: session.order,
    status: session.status,
    capacity: session.capacity,
  );
  return ActivityRecordModel(
    event: eventModel,
    attendancePerSession: [
      SessionAttendanceModel(
        session: sessionModel,
        status: AttendanceStatus.present,
        checkedInAt: tFixedDate,
      ),
    ],
  );
}
