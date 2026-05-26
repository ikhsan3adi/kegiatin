import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/repositories/archive_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetArchivesParams {
  final String sessionId;

  const GetArchivesParams({required this.sessionId});
}

class GetArchivesUseCase extends UseCase<List<ArchiveItem>, GetArchivesParams> {
  final ArchiveRepository repository;

  GetArchivesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ArchiveItem>>> call(GetArchivesParams params) async {
    return repository.getArchives(params.sessionId);
  }
}
