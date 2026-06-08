import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/auth_response.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GoogleLoginUseCase extends UseCase<AuthResponse, String> {
  final AuthRepository _repository;

  GoogleLoginUseCase(this._repository);

  @override
  Future<Either<Failure, AuthResponse>> call(String idToken) =>
      _repository.loginWithGoogle(idToken);
}
