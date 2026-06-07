import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchiveItem>> createArchive({
    required String sessionId,
    required String title,
    required ArchiveType type,
    required String fileUrl,
  });
  Future<Either<Failure, List<ArchiveItem>>> getArchives(String sessionId);
  Future<Either<Failure, String>> uploadImage(String filePath);
  Future<Either<Failure, void>> deleteArchive(String id);
  Future<Either<Failure, ArchiveItem>> downloadArchive(ArchiveItem item);
}
