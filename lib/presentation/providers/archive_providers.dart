import 'package:kegiatin/data/datasources/remote/archive_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/uploads_remote_datasource.dart';
import 'package:kegiatin/data/repositories/archive_repository_impl.dart';
import 'package:kegiatin/domain/repositories/archive_repository.dart';
import 'package:kegiatin/domain/usecases/archive/delete_archive_usecase.dart';
import 'package:kegiatin/domain/usecases/archive/get_archives_usecase.dart';
import 'package:kegiatin/domain/usecases/archive/upload_materi_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'archive_providers.g.dart';

@Riverpod(keepAlive: true)
ArchiveRemoteDataSource archiveRemoteDataSource(Ref ref) =>
    ArchiveRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
UploadsRemoteDataSource uploadsRemoteDataSource(Ref ref) =>
    UploadsRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
ArchiveRepository archiveRepository(Ref ref) => ArchiveRepositoryImpl(
  archiveRemoteDataSource: ref.watch(archiveRemoteDataSourceProvider),
  uploadsRemoteDataSource: ref.watch(uploadsRemoteDataSourceProvider),
  localDataSource: ref.watch(archiveLocalDataSourceProvider),
  networkInfo: ref.watch(networkInfoProvider),
);

@riverpod
UploadMateriUseCase uploadMateriUseCase(Ref ref) =>
    UploadMateriUseCase(ref.watch(archiveRepositoryProvider));

@riverpod
GetArchivesUseCase getArchivesUseCase(Ref ref) =>
    GetArchivesUseCase(ref.watch(archiveRepositoryProvider));

@riverpod
DeleteArchiveUseCase deleteArchiveUseCase(Ref ref) =>
    DeleteArchiveUseCase(ref.watch(archiveRepositoryProvider));
