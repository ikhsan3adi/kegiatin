import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/auth_response.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register(RegisterInput input);
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, String>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> verifyEmail(String token);
  Future<Either<Failure, User>> getCurrentUser();
  Future<void> logout();
}
