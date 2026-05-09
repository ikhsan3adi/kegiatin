import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class StartEventUseCase implements UseCase<Event, String> {
  final EventRepository repository;

  StartEventUseCase(this.repository);

  @override
  Future<Either<Failure, Event>> call(String params) async {
    return await repository.startEvent(params);
  }
}
