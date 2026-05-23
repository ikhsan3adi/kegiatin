import 'package:fpdart/fpdart.dart';
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

  ArchiveRepositoryImpl({
    required this.archiveRemoteDataSource,
    required this.uploadsRemoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
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
        await localDataSource.cacheArchives(sessionId, models);
        return Right(models.map(_toEntity).toList());
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

  ArchiveItem _toEntity(ArchiveModel model) => ArchiveItem(
    id: model.id,
    sessionId: model.sessionId,
    title: model.title,
    type: model.type,
    fileUrl: model.fileUrl,
    createdAt: model.createdAt,
  );
}
