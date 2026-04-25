import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/entities/session_input.dart';

abstract class SessionRepository {
  Future<Either<Failure, Session>> addSession(String eventId, SessionInput input);
  Future<Either<Failure, Session>> updateSession(
    String id, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? capacity,
  });
  Future<Either<Failure, void>> deleteSession(String id);
}
