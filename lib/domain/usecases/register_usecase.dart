import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/auth_response.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class RegisterUseCase extends UseCase<AuthResponse, RegisterInput> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, AuthResponse>> call(RegisterInput input) =>
      _repository.register(input);
}
