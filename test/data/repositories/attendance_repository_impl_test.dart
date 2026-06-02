import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/models/attendance_model.dart';
import 'package:kegiatin/data/models/sync_result_model.dart';
import 'package:kegiatin/data/repositories/attendance_repository_impl.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockAttendanceRemoteDataSource remoteDataSource;
  late MockAttendanceLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late MockRsvpLocalDataSource rsvpLocalDataSource;
  late AttendanceRepositoryImpl repository;

  setUpAll(() {
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    remoteDataSource = MockAttendanceRemoteDataSource();
    localDataSource = MockAttendanceLocalDataSource();
    networkInfo = MockNetworkInfo();
    rsvpLocalDataSource = MockRsvpLocalDataSource();
    repository = AttendanceRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
      rsvpLocalDataSource: rsvpLocalDataSource,
    );
  });

  group('scanQr', () {
    test('returns remote result + saves locally when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final att = tAttendance();
      final model = _attModel(att);
      when(
        () => remoteDataSource.scanQr(
          qrToken: any(named: 'qrToken'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenAnswer((_) async => model);
      when(() => localDataSource.saveRecord(any())).thenAnswer((_) async {});

      final result = await repository.scanQr('qr-token', 'session-1');

      expect(result.isRight(), true);
      verify(() => localDataSource.saveRecord(any())).called(1);
    });

    test('returns ServerFailure on exception when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.scanQr(
          qrToken: any(named: 'qrToken'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenThrow(const ServerException('Error'));

      final result = await repository.scanQr('qr-token', 'session-1');

      expect(result.isLeft(), true);
    });

    test('returns CacheFailure for duplicate QR when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.isDuplicateByQrToken(any(), any())).thenAnswer((_) async => true);

      final result = await repository.scanQr('qr-token', 'session-1');

      expect(result.isLeft(), true);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });

    test('creates local record when valid QR found offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.isDuplicateByQrToken(any(), any())).thenAnswer((_) async => false);
      when(
        () => rsvpLocalDataSource.getRsvpByQrToken(any()),
      ).thenAnswer((_) async => tRsvpWithUser());
      when(() => localDataSource.saveRecord(any())).thenAnswer((_) async {});

      final result = await repository.scanQr('qr-token', 'session-1');

      expect(result.isRight(), true);
    });

    test('returns CacheFailure when QR not found offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.isDuplicateByQrToken(any(), any())).thenAnswer((_) async => false);
      when(() => rsvpLocalDataSource.getRsvpByQrToken(any())).thenAnswer((_) async => null);

      final result = await repository.scanQr('invalid-qr', 'session-1');

      expect(result.isLeft(), true);
    });
  });

  group('syncPendingAttendance', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.syncPendingAttendance();

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(void) when no pending records', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => localDataSource.getPendingRecords()).thenAnswer((_) async => []);

      final result = await repository.syncPendingAttendance();

      expect(result, const Right(null));
    });

    test('syncs pending records and marks SYNCED', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final pending = [_attModel(tAttendance(syncStatus: SyncStatus.pending))];
      when(() => localDataSource.getPendingRecords()).thenAnswer((_) async => pending);
      when(() => localDataSource.updateSyncStatus(any(), any())).thenAnswer((_) async {});
      when(() => remoteDataSource.syncBatch(any())).thenAnswer(
        (_) async => SyncResultResponse(
          results: [SyncResultItem(localId: _attModel(tAttendance()).id, status: 'SYNCED')],
          summary: const SyncResultSummary(synced: 1, conflict: 0, invalid: 0),
        ),
      );

      final result = await repository.syncPendingAttendance();

      expect(result, const Right(null));
      verify(() => localDataSource.updateSyncStatus(any(), SyncStatus.syncing)).called(1);
      verify(() => localDataSource.updateSyncStatus(any(), SyncStatus.synced)).called(1);
    });

    test('marks CONFLICT for server-rejected records', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final pending = [_attModel(tAttendance(syncStatus: SyncStatus.pending))];
      when(() => localDataSource.getPendingRecords()).thenAnswer((_) async => pending);
      when(() => localDataSource.updateSyncStatus(any(), any())).thenAnswer((_) async {});
      when(() => remoteDataSource.syncBatch(any())).thenAnswer(
        (_) async => SyncResultResponse(
          results: [SyncResultItem(localId: _attModel(tAttendance()).id, status: 'CONFLICT')],
          summary: const SyncResultSummary(synced: 0, conflict: 1, invalid: 0),
        ),
      );

      final result = await repository.syncPendingAttendance();

      expect(result, const Right(null));
      verify(() => localDataSource.updateSyncStatus(any(), SyncStatus.conflict)).called(1);
    });

    test('returns ServerFailure on exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => localDataSource.getPendingRecords(),
      ).thenAnswer((_) async => [_attModel(tAttendance(syncStatus: SyncStatus.pending))]);
      when(() => localDataSource.updateSyncStatus(any(), any())).thenAnswer((_) async {});
      when(() => remoteDataSource.syncBatch(any())).thenThrow(const ServerException('Sync error'));

      final result = await repository.syncPendingAttendance();

      expect(result.isLeft(), true);
    });
  });

  group('getAttendanceBySession', () {
    test('returns remote data when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final att = tAttendance();
      final model = _attModel(att);
      when(
        () => remoteDataSource.getSessionAttendance(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => PaginatedResult<AttendanceModel>(data: [model], total: 1, page: 1, limit: 100),
      );

      final result = await repository.getAttendanceBySession('session-1');

      expect(result.isRight(), true);
    });

    test('returns ServerFailure on remote exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getSessionAttendance(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const ServerException('Error'));

      final result = await repository.getAttendanceBySession('session-1');

      expect(result.isLeft(), true);
    });

    test('returns local cached data when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final att = tAttendance();
      final model = _attModel(att);
      when(() => localDataSource.getRecordsBySession(any())).thenAnswer((_) async => [model]);

      final result = await repository.getAttendanceBySession('session-1');

      expect(result.isRight(), true);
    });

    test('returns CacheFailure on local exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => localDataSource.getRecordsBySession(any()),
      ).thenThrow(const CacheException('Error'));

      final result = await repository.getAttendanceBySession('session-1');

      expect(result.isLeft(), true);
    });
  });
}

AttendanceModel _attModel(Attendance att) => AttendanceModel(
  id: att.id,
  userId: att.userId,
  sessionId: att.sessionId,
  rsvpId: att.rsvpId,
  status: att.status,
  syncStatus: att.syncStatus,
  checkedInAt: att.checkedInAt,
  syncedAt: att.syncedAt,
  createdAt: att.createdAt,
);
