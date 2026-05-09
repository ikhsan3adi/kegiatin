import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class CompleteEventUseCase implements UseCase<Event, String> {
  final EventRepository repository;

  CompleteEventUseCase(this.repository);

  @override
  Future<Either<Failure, Event>> call(String params) async {
    return await repository.completeEvent(params);
  }
}
