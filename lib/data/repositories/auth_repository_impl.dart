import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/auth_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kegiatin/domain/entities/auth_response.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthResponse>> login(String email, String password) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.login(email, password);
      await localDataSource.saveTokens(response.accessToken, response.refreshToken);
      await localDataSource.saveUser(response.user);
      return Right(response.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(RegisterInput input) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.register(input);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getCachedUser();
      if (cached != null) return Right(cached.toEntity());
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(userModel);
      return Right(userModel.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedUser();
      if (cached != null) return Right(cached.toEntity());
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      final cached = await localDataSource.getCachedUser();
      if (cached != null) return Right(cached.toEntity());
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final newAccessToken = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveTokens(newAccessToken, refreshToken);
      return Right(newAccessToken);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    return const Left(ServerFailure('Endpoint belum tersedia'));
  }

  @override
  Future<void> logout() async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.logout();
    }
    await localDataSource.clearAll();
  }
}
