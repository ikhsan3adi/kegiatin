import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class PublishEventUseCase extends UseCase<Event, String> {
  final EventRepository repository;

  PublishEventUseCase(this.repository);

  @override
  Future<Either<Failure, Event>> call(String input) =>
      repository.publishEvent(input);
}
