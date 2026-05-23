import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class ScanDocumentUseCase extends UseCase<ProcessedImage, EnhancementMode> {
  final PcdRepository repository;

  ScanDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, ProcessedImage>> call(EnhancementMode mode) async {
    final captureResult = await repository.captureDocument();
    if (captureResult == null) {
      return const Left(CacheFailure('Scan dibatalkan atau gagal'));
    }

    return repository.enhanceAndSave(
      imageBytes: captureResult.imageBytes,
      mode: mode,
      isDocumentScan: true,
    );
  }
}
