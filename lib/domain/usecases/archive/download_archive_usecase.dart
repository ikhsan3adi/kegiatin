import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/repositories/archive_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class DownloadArchiveUseCase extends UseCase<ArchiveItem, ArchiveItem> {
  final ArchiveRepository repository;

  DownloadArchiveUseCase(this.repository);

  @override
  Future<Either<Failure, ArchiveItem>> call(ArchiveItem params) {
    return repository.downloadArchive(params);
  }
}
