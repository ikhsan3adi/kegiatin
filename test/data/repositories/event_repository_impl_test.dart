import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/models/event_model.dart';
import 'package:kegiatin/data/repositories/event_repository_impl.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockEventRemoteDataSource remoteDataSource;
  late MockEventLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late EventRepositoryImpl repository;

  setUpAll(() {
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    remoteDataSource = MockEventRemoteDataSource();
    localDataSource = MockEventLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = EventRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  group('getEvents', () {
    test('returns cached events when cache not empty (no forceRefresh)', () async {
      final event = tEvent();
      final model = _toModel(event);
      when(() => localDataSource.getCachedEvents()).thenAnswer((_) async => [model]);

      final result = await repository.getEvents();

      expect(result.isRight(), true);
      verifyNever(
        () =>
            remoteDataSource.getEvents(page: 1, limit: 10, status: null, type: null, search: null),
      );
    });

    test('fetches remote when forceRefresh=true despite cache', () async {
      when(() => localDataSource.getCachedEvents()).thenAnswer((_) async => []);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(
        () => remoteDataSource.getEvents(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          status: any(named: 'status'),
          type: any(named: 'type'),
          search: any(named: 'search'),
        ),
      ).thenAnswer(
        (_) async => PaginatedResult<EventModel>(data: [model], total: 1, page: 1, limit: 10),
      );
      when(() => localDataSource.cacheEvents(any())).thenAnswer((_) async {});

      final result = await repository.getEvents(forceRefresh: true);

      expect(result.isRight(), true);
    });

    test('fetches remote + caches when online', () async {
      when(() => localDataSource.getCachedEvents()).thenAnswer((_) async => []);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(
        () => remoteDataSource.getEvents(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          status: any(named: 'status'),
          type: any(named: 'type'),
          search: any(named: 'search'),
        ),
      ).thenAnswer(
        (_) async => PaginatedResult<EventModel>(data: [model], total: 1, page: 1, limit: 10),
      );
      when(() => localDataSource.cacheEvents(any())).thenAnswer((_) async {});

      final result = await repository.getEvents();

      expect(result.isRight(), true);
      verify(() => localDataSource.cacheEvents(any())).called(1);
    });

    test('returns cached when offline + cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final event = tEvent();
      final model = _toModel(event);
      when(() => localDataSource.getCachedEvents()).thenAnswer((_) async => [model]);

      final result = await repository.getEvents();

      expect(result.isRight(), true);
    });

    test('returns NetworkFailure when offline + no cache', () async {
      when(() => localDataSource.getCachedEvents()).thenAnswer((_) async => []);
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getCachedEvents()).thenAnswer((_) async => []);

      final result = await repository.getEvents();

      expect(result, const Left(NetworkFailure()));
    });
  });

  group('getEventById', () {
    test('returns remote + cache when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(() => remoteDataSource.getEventById(any())).thenAnswer((_) async => model);
      when(() => localDataSource.cacheEvent(any())).thenAnswer((_) async {});

      final result = await repository.getEventById('event-1');

      expect(result.isRight(), true);
    });

    test('fallback to cache when online + ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.getEventById(any())).thenThrow(const ServerException('Error'));
      final event = tEvent();
      final model = _toModel(event);
      when(() => localDataSource.getCachedEventById(any())).thenAnswer((_) async => model);

      final result = await repository.getEventById('event-1');

      expect(result.isRight(), true);
    });

    test('returns cached when offline + cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final event = tEvent();
      final model = _toModel(event);
      when(() => localDataSource.getCachedEventById(any())).thenAnswer((_) async => model);

      final result = await repository.getEventById('event-1');

      expect(result.isRight(), true);
    });

    test('returns NetworkFailure when offline + no cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getCachedEventById(any())).thenAnswer((_) async => null);

      final result = await repository.getEventById('event-1');

      expect(result, const Left(NetworkFailure()));
    });
  });

  group('createEvent', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.createEvent(tCreateEventInput());

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Event) on success + caches locally', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(() => remoteDataSource.createEvent(any())).thenAnswer((_) async => model);
      when(() => localDataSource.cacheEvent(model)).thenAnswer((_) async {});

      final result = await repository.createEvent(tCreateEventInput());

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.createEvent(any())).thenThrow(const ServerException('Error'));

      final result = await repository.createEvent(tCreateEventInput());

      expect(result.isLeft(), true);
    });
  });

  group('updateEvent', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateEvent('event-1', tUpdateEventInput());

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Event) on success + caches locally', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(() => remoteDataSource.updateEvent(any(), any())).thenAnswer((_) async => model);
      when(() => localDataSource.cacheEvent(model)).thenAnswer((_) async {});

      final result = await repository.updateEvent('event-1', tUpdateEventInput());

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.updateEvent(any(), any()),
      ).thenThrow(const ServerException('Error'));

      final result = await repository.updateEvent('event-1', tUpdateEventInput());

      expect(result.isLeft(), true);
    });
  });

  group('deleteEvent', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.deleteEvent('event-1');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(void) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.deleteEvent(any())).thenAnswer((_) async {});
      when(() => localDataSource.getCachedEventById(any())).thenAnswer((_) async => null);

      final result = await repository.deleteEvent('event-1');

      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.deleteEvent(any())).thenThrow(const ServerException('Error'));

      final result = await repository.deleteEvent('event-1');

      expect(result.isLeft(), true);
    });
  });

  group('publishEvent', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.publishEvent('event-1');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Event) on success + caches locally', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(() => remoteDataSource.publishEvent(any())).thenAnswer((_) async => model);
      when(() => localDataSource.cacheEvent(model)).thenAnswer((_) async {});

      final result = await repository.publishEvent('event-1');

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.publishEvent(any())).thenThrow(const ServerException('Error'));

      final result = await repository.publishEvent('event-1');

      expect(result.isLeft(), true);
    });
  });

  group('cancelEvent', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.cancelEvent('event-1');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Event) on success + caches locally', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(() => remoteDataSource.cancelEvent(any())).thenAnswer((_) async => model);
      when(() => localDataSource.cacheEvent(model)).thenAnswer((_) async {});

      final result = await repository.cancelEvent('event-1');

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.cancelEvent(any())).thenThrow(const ServerException('Error'));

      final result = await repository.cancelEvent('event-1');

      expect(result.isLeft(), true);
    });
  });

  group('startEvent', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.startEvent('event-1');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Event) on success + caches locally', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(() => remoteDataSource.startEvent(any())).thenAnswer((_) async => model);
      when(() => localDataSource.cacheEvent(model)).thenAnswer((_) async {});

      final result = await repository.startEvent('event-1');

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.startEvent(any())).thenThrow(const ServerException('Error'));

      final result = await repository.startEvent('event-1');

      expect(result.isLeft(), true);
    });
  });

  group('completeEvent', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.completeEvent('event-1');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(Event) on success + caches locally', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final event = tEvent();
      final model = _toModel(event);
      when(() => remoteDataSource.completeEvent(any())).thenAnswer((_) async => model);
      when(() => localDataSource.cacheEvent(model)).thenAnswer((_) async {});

      final result = await repository.completeEvent('event-1');

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.completeEvent(any())).thenThrow(const ServerException('Error'));

      final result = await repository.completeEvent('event-1');

      expect(result.isLeft(), true);
    });
  });
}

EventModel _toModel(Event event) => EventModel(
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
