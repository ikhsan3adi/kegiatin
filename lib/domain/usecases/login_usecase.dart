import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/auth_response.dart';
import 'package:kegiatin/domain/entities/login_input.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class LoginUseCase extends UseCase<AuthResponse, LoginInput> {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Either<Failure, AuthResponse>> call(LoginInput input) =>
      _repository.login(input.email, input.password);
}
