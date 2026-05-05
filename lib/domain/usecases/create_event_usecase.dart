import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class CreateEventUseCase extends UseCase<Event, CreateEventInput> {
  final EventRepository repository;

  CreateEventUseCase(this.repository);

  @override
  Future<Either<Failure, Event>> call(CreateEventInput input) =>
      repository.createEvent(input);
}
