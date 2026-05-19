import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/remote/session_remote_datasource.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SessionRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, Session>> addSession(String eventId, SessionInput input) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await remoteDataSource.addSession(eventId, input);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Session>> updateSession(
    String id, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? capacity,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await remoteDataSource.updateSession(
        id,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        capacity: capacity,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.deleteSession(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
