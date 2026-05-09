import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetCurrentUserUseCase extends UseCase<User, NoInput> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(NoInput input) => _repository.getCurrentUser();
}
