import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';

class CaptureResult {
  const CaptureResult({required this.imageBytes});
  final Uint8List imageBytes;
}

abstract class PcdRepository {
  Future<List<CaptureResult>?> captureDocument({int pageLimit = 1});
  Future<CaptureResult?> capturePhoto();
  Future<Either<Failure, ProcessedImage>> enhanceAndSave({
    required Uint8List imageBytes,
    required EnhancementMode mode,
    required bool isDocumentScan,
  });
}
