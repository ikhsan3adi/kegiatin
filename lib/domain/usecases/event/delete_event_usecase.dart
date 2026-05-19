import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class DeleteEventUseCase implements UseCase<void, String> {
  final EventRepository repository;

  DeleteEventUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteEvent(params);
  }
}
