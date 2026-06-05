import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/models/rsvp_model.dart';
import 'package:kegiatin/data/repositories/rsvp_repository_impl.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockRsvpRemoteDataSource remoteDataSource;
  late MockRsvpLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late RsvpRepositoryImpl repository;

  setUpAll(() {
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    remoteDataSource = MockRsvpRemoteDataSource();
    localDataSource = MockRsvpLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = RsvpRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  group('createRsvp', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.createRsvp('event-1');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Rsvp) + cache locally on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final rsvpEntity = tRsvp();
      final rsvpModel = RsvpModel(
        id: rsvpEntity.id,
        userId: rsvpEntity.userId,
        eventId: rsvpEntity.eventId,
        qrToken: rsvpEntity.qrToken,
        status: rsvpEntity.status,
        createdAt: rsvpEntity.createdAt,
      );
      when(() => remoteDataSource.createRsvp(any())).thenAnswer((_) async => rsvpModel);
      when(() => localDataSource.cacheRsvp(any())).thenAnswer((_) async {});

      final result = await repository.createRsvp('event-1');

      expect(result.isRight(), true);
      verify(() => remoteDataSource.createRsvp('event-1')).called(1);
      verify(() => localDataSource.cacheRsvp(any())).called(1);
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.createRsvp(any())).thenThrow(Exception('Error'));

      final result = await repository.createRsvp('event-1');

      expect(result.isLeft(), true);
    });
  });

  group('inviteUser', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.inviteUser('event-1', 'user-2');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Rsvp) on success (no local cache)', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final rsvpEntity = tRsvp();
      final rsvpModel = RsvpModel(
        id: rsvpEntity.id,
        userId: rsvpEntity.userId,
        eventId: rsvpEntity.eventId,
        qrToken: rsvpEntity.qrToken,
        status: rsvpEntity.status,
        createdAt: rsvpEntity.createdAt,
      );
      when(() => remoteDataSource.inviteUser(any(), any())).thenAnswer((_) async => rsvpModel);

      final result = await repository.inviteUser('event-1', 'user-2');

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.inviteUser(any(), any())).thenThrow(Exception('Error'));

      final result = await repository.inviteUser('event-1', 'user-2');

      expect(result.isLeft(), true);
    });
  });

  group('getMyRsvps', () {
    test('returns remote + cache when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final rsvpEntity = tRsvp();
      final rsvpModel = RsvpModel(
        id: rsvpEntity.id,
        userId: rsvpEntity.userId,
        eventId: rsvpEntity.eventId,
        qrToken: rsvpEntity.qrToken,
        status: rsvpEntity.status,
        createdAt: rsvpEntity.createdAt,
      );
      when(
        () => remoteDataSource.getMyRsvps(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => PaginatedResult<RsvpModel>(data: [rsvpModel], total: 1, page: 1, limit: 20),
      );
      when(() => localDataSource.cacheRsvp(any())).thenAnswer((_) async {});

      final result = await repository.getMyRsvps();

      expect(result.isRight(), true);
    });

    test('returns cached data when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final rsvpEntity = tRsvp();
      final rsvpModel = RsvpModel(
        id: rsvpEntity.id,
        userId: rsvpEntity.userId,
        eventId: rsvpEntity.eventId,
        qrToken: rsvpEntity.qrToken,
        status: rsvpEntity.status,
        createdAt: rsvpEntity.createdAt,
      );
      when(() => localDataSource.getAllCachedRsvps()).thenAnswer((_) async => [rsvpModel]);

      final result = await repository.getMyRsvps();

      expect(result.isRight(), true);
    });
  });

  group('getEventRsvps', () {
    test('returns remote result when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final rsvpWithUser = tRsvpWithUser();
      final paginated = PaginatedResult<RsvpWithUser>(
        data: [rsvpWithUser],
        total: 1,
        page: 1,
        limit: 100,
      );
      when(
        () => remoteDataSource.getEventRsvps(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
        ),
      ).thenAnswer((_) async => paginated);
      when(() => localDataSource.cacheRsvps(any(), any())).thenAnswer((_) async {});

      final result = await repository.getEventRsvps('event-1');

      expect(result.isRight(), true);
    });

    test('falls back to cached data on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getEventRsvps(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
        ),
      ).thenThrow(const ServerException('Error'));
      when(() => localDataSource.getCachedRsvps(any())).thenAnswer((_) async => [tRsvpWithUser()]);

      final result = await repository.getEventRsvps('event-1');

      expect(result.isRight(), true);
    });

    test('returns NetworkFailure when offline + no cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getCachedRsvps(any())).thenAnswer((_) async => []);

      final result = await repository.getEventRsvps('event-1');

      expect(result, const Left(NetworkFailure()));
    });
  });
}
