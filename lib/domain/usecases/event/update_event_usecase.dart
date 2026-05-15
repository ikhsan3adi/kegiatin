import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class UpdateEventUseCase extends UseCase<Event, UpdateEventUseCaseParams> {
  final EventRepository _repository;

  UpdateEventUseCase(this._repository);

  @override
  Future<Either<Failure, Event>> call(UpdateEventUseCaseParams input) async {
    return _repository.updateEvent(input.eventId, input.input);
  }
}

class UpdateEventUseCaseParams {
  final String eventId;
  final UpdateEventInput input;

  const UpdateEventUseCaseParams({
    required this.eventId,
    required this.input,
  });
}
