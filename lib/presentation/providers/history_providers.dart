import 'package:kegiatin/data/datasources/remote/history_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/profile_remote_datasource.dart';
import 'package:kegiatin/data/repositories/profile_repository_impl.dart';
import 'package:kegiatin/domain/repositories/profile_repository.dart';
import 'package:kegiatin/domain/usecases/get_history_usecase.dart';
import 'package:kegiatin/domain/usecases/profile/update_profile_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) =>
    ProfileRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
HistoryRemoteDataSource historyRemoteDataSource(Ref ref) =>
    HistoryRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  historyRemoteDataSource: ref.watch(historyRemoteDataSourceProvider),
  historyLocalDataSource: ref.watch(historyLocalDataSourceProvider),
  authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  networkInfo: ref.watch(networkInfoProvider),
);

@riverpod
GetHistoryUseCase getHistoryUseCase(Ref ref) =>
    GetHistoryUseCase(ref.watch(profileRepositoryProvider));

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) =>
    UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
