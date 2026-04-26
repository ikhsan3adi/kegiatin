import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/constants/db_constants.dart';
import 'package:kegiatin/core/network/dio_client.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/auth_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kegiatin/data/repositories/auth_repository_impl.dart';
import 'package:kegiatin/domain/repositories/auth_repository.dart';
import 'package:kegiatin/domain/usecases/get_current_user_usecase.dart';
import 'package:kegiatin/domain/usecases/login_usecase.dart';
import 'package:kegiatin/domain/usecases/logout_usecase.dart';
import 'package:kegiatin/domain/usecases/register_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// DEPENDENCY INJECTION

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('Override di ProviderScope');

@Riverpod(keepAlive: true)
bool hasSeenOnboardingSync(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(DbConstants.hasSeenOnboardingKey) ?? false;
}

@Riverpod(keepAlive: true)
Box<dynamic> authBox(Ref ref) => throw UnimplementedError('Override di ProviderScope');

@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) => NetworkInfoImpl(Connectivity());

@Riverpod(keepAlive: true)
AuthLocalDataSource authLocalDataSource(Ref ref) => AuthLocalDataSourceImpl(
  sharedPreferences: ref.watch(sharedPreferencesProvider),
  authBox: ref.watch(authBoxProvider),
);

@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) =>
    DioClient(dio: Dio(), authLocalDataSource: ref.watch(authLocalDataSourceProvider));

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  localDataSource: ref.watch(authLocalDataSourceProvider),
  networkInfo: ref.watch(networkInfoProvider),
);

@riverpod
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
RegisterUseCase registerUseCase(Ref ref) => RegisterUseCase(ref.watch(authRepositoryProvider));

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) =>
    GetCurrentUserUseCase(ref.watch(authRepositoryProvider));

@riverpod
LogoutUseCase logoutUseCase(Ref ref) => LogoutUseCase(ref.watch(authRepositoryProvider));
