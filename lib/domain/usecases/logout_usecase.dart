import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class LogoutUseCase extends UseCase<void, NoInput> {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoInput input) async {
    await _repository.logout();
    return const Right(null);
  }
}
