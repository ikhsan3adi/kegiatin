import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/models/session_model.dart';
import 'package:kegiatin/data/repositories/session_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockSessionRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;
  late SessionRepositoryImpl repository;

  setUpAll(() {
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    remoteDataSource = MockSessionRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = SessionRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
  });

  group('addSession', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.addSession('event-1', tSessionInput());

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Session) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final session = tSession();
      final model = SessionModel(
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
      when(() => remoteDataSource.addSession(any(), any())).thenAnswer((_) async => model);

      final result = await repository.addSession('event-1', tSessionInput());

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.addSession(any(), any()),
      ).thenThrow(const ServerException('Error', statusCode: 500));

      final result = await repository.addSession('event-1', tSessionInput());

      expect(result.isLeft(), true);
      result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('Expected failure'));
    });
  });

  group('updateSession', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateSession('session-1', title: 'Updated');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Session) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final session = tSession();
      final model = SessionModel(
        id: session.id,
        eventId: session.eventId,
        title: 'Updated',
        startTime: session.startTime,
        endTime: session.endTime,
        location: session.location,
        order: session.order,
        status: session.status,
        capacity: session.capacity,
      );
      when(
        () => remoteDataSource.updateSession(
          any(),
          title: any(named: 'title'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          location: any(named: 'location'),
          capacity: any(named: 'capacity'),
        ),
      ).thenAnswer((_) async => model);

      final result = await repository.updateSession('session-1', title: 'Updated');

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.updateSession(
          any(),
          title: any(named: 'title'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          location: any(named: 'location'),
          capacity: any(named: 'capacity'),
        ),
      ).thenThrow(const ServerException('Error'));

      final result = await repository.updateSession('session-1');

      expect(result.isLeft(), true);
    });
  });

  group('deleteSession', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.deleteSession('session-1');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(void) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.deleteSession(any())).thenAnswer((_) async {});

      final result = await repository.deleteSession('session-1');

      expect(result, const Right(null));
      verify(() => remoteDataSource.deleteSession('session-1')).called(1);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.deleteSession(any())).thenThrow(const ServerException('Error'));

      final result = await repository.deleteSession('session-1');

      expect(result.isLeft(), true);
    });
  });
}
