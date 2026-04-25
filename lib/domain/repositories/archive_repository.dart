import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchiveItem>> uploadMaterial({
    required String sessionId,
    required String filePath,
    required String title,
  });
  Future<Either<Failure, List<ArchiveItem>>> getMaterials(String eventId);
}
