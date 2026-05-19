import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetEventRsvpsUseCase extends UseCase<PaginatedResult<RsvpWithUser>, GetEventRsvpsParams> {
  final RsvpRepository repository;

  GetEventRsvpsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResult<RsvpWithUser>>> call(GetEventRsvpsParams params) async {
    return repository.getEventRsvps(params.eventId, page: params.page, limit: params.limit);
  }
}

class GetEventRsvpsParams {
  final String eventId;
  final int page;
  final int limit;

  const GetEventRsvpsParams({required this.eventId, this.page = 1, this.limit = 100});
}
