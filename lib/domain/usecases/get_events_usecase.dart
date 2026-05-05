import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetEventsUseCase extends UseCase<PaginatedResult<Event>, GetEventsUseCaseParams> {
  final EventRepository repository;

  GetEventsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResult<Event>>> call(GetEventsUseCaseParams params) async {
    return await repository.getEvents(
      page: params.page,
      limit: params.limit,
      status: params.status,
      type: params.type,
      search: params.search,
    );
  }
}

class GetEventsUseCaseParams {
  final int page;
  final int limit;
  final EventStatus? status;
  final EventType? type;
  final String? search;

  const GetEventsUseCaseParams({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.type,
    this.search,
  });
}
