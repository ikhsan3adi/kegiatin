import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/archive_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class DeleteArchiveUseCase extends UseCase<void, String> {
  final ArchiveRepository repository;

  DeleteArchiveUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return repository.deleteArchive(id);
  }
}
