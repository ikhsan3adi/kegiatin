import 'package:kegiatin/data/datasources/remote/session_remote_datasource.dart';
import 'package:kegiatin/data/repositories/session_repository_impl.dart';
import 'package:kegiatin/domain/repositories/session_repository.dart';
import 'package:kegiatin/domain/usecases/session/add_session_usecase.dart';
import 'package:kegiatin/domain/usecases/session/delete_session_usecase.dart';
import 'package:kegiatin/domain/usecases/session/update_session_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_providers.g.dart';

@Riverpod(keepAlive: true)
SessionRemoteDataSource sessionRemoteDataSource(Ref ref) =>
    SessionRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
SessionRepository sessionRepository(Ref ref) => SessionRepositoryImpl(
  remoteDataSource: ref.watch(sessionRemoteDataSourceProvider),
  networkInfo: ref.watch(networkInfoProvider),
);

@riverpod
AddSessionUseCase addSessionUseCase(Ref ref) =>
    AddSessionUseCase(ref.watch(sessionRepositoryProvider));

@riverpod
UpdateSessionUseCase updateSessionUseCase(Ref ref) =>
    UpdateSessionUseCase(ref.watch(sessionRepositoryProvider));

@riverpod
DeleteSessionUseCase deleteSessionUseCase(Ref ref) =>
    DeleteSessionUseCase(ref.watch(sessionRepositoryProvider));
