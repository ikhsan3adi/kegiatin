import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/archive_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/archive_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/uploads_remote_datasource.dart';
import 'package:kegiatin/data/models/archive_model.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/repositories/archive_repository.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  final ArchiveRemoteDataSource archiveRemoteDataSource;
  final UploadsRemoteDataSource uploadsRemoteDataSource;
  final ArchiveLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Dio dio;

  ArchiveRepositoryImpl({
    required this.archiveRemoteDataSource,
    required this.uploadsRemoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.dio,
  });

  @override
  Future<Either<Failure, ArchiveItem>> createArchive({
    required String sessionId,
    required String title,
    required ArchiveType type,
    required String fileUrl,
  }) async {
    try {
      final model = await archiveRemoteDataSource.createArchive(
        sessionId: sessionId,
        title: title,
        type: type,
        fileUrl: fileUrl,
      );
      return Right(_toEntity(model));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArchiveItem>>> getArchives(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final models = await archiveRemoteDataSource.getArchives(sessionId);
        final cached = await localDataSource.getCachedArchives(sessionId);

        // Merge localFilePath from existing cache or scan disk physically if cache was cleared (e.g. after logout)
        final mergedModels = await Future.wait(
          models.map((m) async {
            final existing = cached.cast<ArchiveModel?>().firstWhere(
              (c) => c?.id == m.id,
              orElse: () => null,
            );
            if (existing != null && existing.localFilePath != null) {
              if (await File(existing.localFilePath!).exists()) {
                return m.copyWith(localFilePath: existing.localFilePath);
              }
            }

            final localPath = await _getLocalFilePath(m.sessionId, m.fileUrl, m.id);
            if (await File(localPath).exists()) {
              return m.copyWith(localFilePath: localPath);
            }

            return m;
          }),
        );

        await localDataSource.cacheArchives(sessionId, mergedModels);
        return Right(mergedModels.map(_toEntity).toList());
      } on Exception catch (e) {
        final cached = await localDataSource.getCachedArchives(sessionId);
        if (cached.isNotEmpty) return Right(cached.map(_toEntity).toList());
        return Left(ServerFailure(e.toString()));
      }
    }
    final cached = await localDataSource.getCachedArchives(sessionId);
    if (cached.isNotEmpty) return Right(cached.map(_toEntity).toList());
    return const Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, String>> uploadImage(String filePath) async {
    try {
      final url = await uploadsRemoteDataSource.uploadImage(filePath);
      return Right(url);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArchive(String id) async {
    try {
      await archiveRemoteDataSource.deleteArchive(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ArchiveItem>> downloadArchive(ArchiveItem item) async {
    if (item.localFilePath != null) {
      final file = File(item.localFilePath!);
      if (await file.exists()) {
        return Right(item);
      }
    }

    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Koneksi internet diperlukan untuk mengunduh materi.'));
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetDirectory = Directory('${appDir.path}/materials/${item.sessionId}');
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      final resolvedUrl = ApiConstants.resolveImageUrl(item.fileUrl);
      final uri = Uri.parse(resolvedUrl);
      String filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'file_${item.id}';
      filename = filename.replaceAll(RegExp(r'[\\/:\*\?"<>\|]'), '_');
      final savePath = '${targetDirectory.path}/$filename';

      await dio.download(resolvedUrl, savePath);

      final cached = await localDataSource.getCachedArchives(item.sessionId);
      final updatedList = cached.map((model) {
        if (model.id == item.id) {
          return model.copyWith(localFilePath: savePath);
        }
        return model;
      }).toList();
      await localDataSource.cacheArchives(item.sessionId, updatedList);

      final updatedEntity = ArchiveItem(
        id: item.id,
        sessionId: item.sessionId,
        title: item.title,
        type: item.type,
        fileUrl: item.fileUrl,
        createdAt: item.createdAt,
        localFilePath: savePath,
      );
      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure('Gagal mengunduh file materi: $e'));
    }
  }

  Future<String> _getLocalFilePath(String sessionId, String fileUrl, String id) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory('${appDir.path}/materials/$sessionId');
    final resolvedUrl = ApiConstants.resolveImageUrl(fileUrl);
    final uri = Uri.parse(resolvedUrl);
    String filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'file_$id';
    filename = filename.replaceAll(RegExp(r'[\\/:\*\?"<>\|]'), '_');
    return '${targetDirectory.path}/$filename';
  }

  ArchiveItem _toEntity(ArchiveModel model) => ArchiveItem(
    id: model.id,
    sessionId: model.sessionId,
    title: model.title,
    type: model.type,
    fileUrl: model.fileUrl,
    createdAt: model.createdAt,
    localFilePath: model.localFilePath,
  );
}
