import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/rsvp_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/rsvp_remote_datasource.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';

class RsvpRepositoryImpl implements RsvpRepository {
  final RsvpRemoteDataSource remoteDataSource;
  final RsvpLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RsvpRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Rsvp>> createRsvp(String eventId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.createRsvp(eventId);
      await localDataSource.cacheRsvp(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Rsvp>>> getMyRsvps({int page = 1, int limit = 20}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getMyRsvps(page: page, limit: limit);
        for (final rsvp in result.data) {
          await localDataSource.cacheRsvp(rsvp);
        }
        return Right(
          PaginatedResult<Rsvp>(
            data: result.data.toList(),
            total: result.total,
            page: result.page,
            limit: result.limit,
          ),
        );
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    final cached = await localDataSource.getAllCachedRsvps();
    return Right(
      PaginatedResult<Rsvp>(data: cached, total: cached.length, page: 1, limit: cached.length),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<RsvpWithUser>>> getEventRsvps(
    String eventId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getEventRsvps(
          eventId,
          page: page,
          limit: limit,
          search: search,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure());
  }
}
