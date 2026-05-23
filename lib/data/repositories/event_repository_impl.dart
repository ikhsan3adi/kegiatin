import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/event_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/event_remote_datasource.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final EventLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedResult<Event>>> getEvents({
    int page = 1,
    int limit = 10,
    EventStatus? status,
    EventType? type,
    String? search,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await localDataSource.getCachedEvents();
      if (cached.isNotEmpty) {
        return Right(
          PaginatedResult<Event>(data: cached, total: cached.length, page: 1, limit: cached.length),
        );
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getEvents(
          page: page,
          limit: limit,
          status: status,
          type: type,
          search: search,
        );
        await localDataSource.cacheEvents(result.data.toList());
        return Right(
          PaginatedResult<Event>(
            data: result.data.toList(),
            total: result.total,
            page: result.page,
            limit: result.limit,
          ),
        );
      } on ServerException catch (e) {
        if (!forceRefresh) {
          final cached = await localDataSource.getCachedEvents();
          if (cached.isNotEmpty) {
            return Right(
              PaginatedResult<Event>(
                data: cached,
                total: cached.length,
                page: 1,
                limit: cached.length,
              ),
            );
          }
        }
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      }
    }
    final cached = await localDataSource.getCachedEvents();
    if (cached.isNotEmpty) {
      return Right(
        PaginatedResult<Event>(data: cached, total: cached.length, page: 1, limit: cached.length),
      );
    }
    return const Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, Event>> getEventById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getEventById(id);
        await localDataSource.cacheEvent(result);
        return Right(result);
      } on ServerException catch (e) {
        final cached = await localDataSource.getCachedEventById(id);
        if (cached != null) return Right(cached);
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      }
    }
    final cached = await localDataSource.getCachedEventById(id);
    if (cached != null) return Right(cached);
    return const Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, Event>> createEvent(CreateEventInput input) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.createEvent(input);
      await localDataSource.cacheEvent(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(String id, UpdateEventInput input) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.updateEvent(id, input);
      await localDataSource.cacheEvent(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.deleteEvent(id);
      await localDataSource.getCachedEventById(id).then((cached) async {
        if (cached != null) {
          await localDataSource.cacheEvents(
            (await localDataSource.getCachedEvents()).where((e) => e.id != id).toList(),
          );
        }
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> publishEvent(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.publishEvent(id);
      await localDataSource.cacheEvent(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> cancelEvent(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.cancelEvent(id);
      await localDataSource.cacheEvent(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> startEvent(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.startEvent(id);
      await localDataSource.cacheEvent(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> completeEvent(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.completeEvent(id);
      await localDataSource.cacheEvent(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
