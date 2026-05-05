import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
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
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Event>> createEvent(CreateEventInput input) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final model = await remoteDataSource.createEvent(input);
      return Right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Metode berikut belum diimplementasi; akan ditambahkan pada iterasi berikutnya.
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, PaginatedResult<Event>>> getEvents({
    int page = 1,
    int limit = 10,
    EventStatus? status,
    EventType? type,
    String? search,
  }) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }

  @override
  Future<Either<Failure, Event>> getEventById(String id) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }

  @override
  Future<Either<Failure, Event>> updateEvent(
    String id,
    UpdateEventInput input,
  ) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }

  @override
  Future<Either<Failure, Event>> publishEvent(String id) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }

  @override
  Future<Either<Failure, Event>> cancelEvent(String id) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }
}
