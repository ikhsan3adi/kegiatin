import 'package:kegiatin/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kegiatin/data/repositories/auth_repository_impl.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/usecases/get_current_user_usecase.dart';
import 'package:kegiatin/domain/usecases/login_usecase.dart';
import 'package:kegiatin/domain/usecases/logout_usecase.dart';
import 'package:kegiatin/domain/usecases/register_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Auth remote DS, repository, and use cases.

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  localDataSource: ref.watch(authLocalDataSourceProvider),
  networkInfo: ref.watch(networkInfoProvider),
);

@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
RegisterUseCase registerUseCase(Ref ref) => RegisterUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) =>
    GetCurrentUserUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
LogoutUseCase logoutUseCase(Ref ref) => LogoutUseCase(ref.watch(authRepositoryProvider));
