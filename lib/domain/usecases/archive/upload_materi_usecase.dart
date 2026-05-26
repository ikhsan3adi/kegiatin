import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/repositories/archive_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class UploadMateriParams {
  final String sessionId;
  final String title;
  final ArchiveType type;
  final String? filePath;
  final String? linkUrl;

  const UploadMateriParams({
    required this.sessionId,
    required this.title,
    required this.type,
    this.filePath,
    this.linkUrl,
  });
}

class UploadMateriUseCase extends UseCase<ArchiveItem, UploadMateriParams> {
  final ArchiveRepository repository;

  UploadMateriUseCase(this.repository);

  @override
  Future<Either<Failure, ArchiveItem>> call(UploadMateriParams params) async {
    if (params.type == ArchiveType.material && params.linkUrl != null) {
      return repository.createArchive(
        sessionId: params.sessionId,
        title: params.title,
        type: params.type,
        fileUrl: params.linkUrl!,
      );
    }

    if (params.filePath == null) {
      return const Left(CacheFailure('File atau link harus disediakan'));
    }

    final uploadResult = await repository.uploadImage(params.filePath!);
    return uploadResult.fold(
      (failure) => Left(failure),
      (url) => repository.createArchive(
        sessionId: params.sessionId,
        title: params.title,
        type: params.type,
        fileUrl: url,
      ),
    );
  }
}
