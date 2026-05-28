import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';

abstract class RsvpRepository {
  Future<Either<Failure, Rsvp>> createRsvp(String eventId);

  Future<Either<Failure, Rsvp>> inviteUser(String eventId, String userId);

  Future<Either<Failure, PaginatedResult<Rsvp>>> getMyRsvps({int page = 1, int limit = 20});

  Future<Either<Failure, PaginatedResult<RsvpWithUser>>> getEventRsvps(
    String eventId, {
    int page = 1,
    int limit = 100,
    String? search,
  });
}
