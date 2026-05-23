import 'package:kegiatin/data/datasources/remote/history_remote_datasource.dart';
import 'package:kegiatin/data/repositories/profile_repository_impl.dart';
import 'package:kegiatin/domain/repositories/profile_repository.dart';
import 'package:kegiatin/domain/usecases/get_history_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_providers.g.dart';

@Riverpod(keepAlive: true)
HistoryRemoteDataSource historyRemoteDataSource(Ref ref) =>
    HistoryRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  historyRemoteDataSource: ref.watch(historyRemoteDataSourceProvider),
  historyLocalDataSource: ref.watch(historyLocalDataSourceProvider),
  networkInfo: ref.watch(networkInfoProvider),
);

@riverpod
GetHistoryUseCase getHistoryUseCase(Ref ref) =>
    GetHistoryUseCase(ref.watch(profileRepositoryProvider));
