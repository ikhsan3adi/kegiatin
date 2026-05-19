import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/session_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class DeleteSessionUseCase implements UseCase<void, String> {
  final SessionRepository repository;

  DeleteSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return repository.deleteSession(id);
  }
}
