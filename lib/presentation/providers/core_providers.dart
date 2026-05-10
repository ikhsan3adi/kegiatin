import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/constants/db_constants.dart';
import 'package:kegiatin/core/network/dio_client.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/auth_local_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'core_providers.g.dart';

/// Infra & shared dependencies (prefs, Hive, network, Dio, auth local DS).

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
