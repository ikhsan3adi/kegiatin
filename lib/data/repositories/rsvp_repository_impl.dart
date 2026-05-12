import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/datasources/remote/rsvp_remote_datasource.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';

class RsvpRepositoryImpl implements RsvpRepository {
  final RsvpRemoteDataSource remoteDataSource;

  RsvpRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Rsvp>> createRsvp(String eventId) async {
    try {
      final result = await remoteDataSource.createRsvp(eventId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Rsvp>>> getMyRsvps({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.getMyRsvps(page: page, limit: limit);
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
}
