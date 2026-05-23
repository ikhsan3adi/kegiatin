import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/core/pcd/image_enhancer.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:path_provider/path_provider.dart';

class PcdRepositoryImpl implements PcdRepository {
  @override
  Future<CaptureResult?> captureDocument({int pageLimit = 1}) async {
    final options = DocumentScannerOptions(
      documentFormats: const {DocumentFormat.jpeg},
      mode: ScannerMode.filter,
      pageLimit: pageLimit,
      isGalleryImport: true,
    );

    final scanner = DocumentScanner(options: options);

    try {
      final result = await scanner.scanDocument();
      final images = result.images;
      if (images == null || images.isEmpty) return null;

      final imagePath = images.first;
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      return CaptureResult(imageBytes: bytes);
    } on PlatformException {
      return null;
    } finally {
      await scanner.close();
    }
  }

  @override
  Future<CaptureResult?> capturePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);

    if (picked == null) return null;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();

    return CaptureResult(imageBytes: bytes);
  }

  @override
  Future<Either<Failure, ProcessedImage>> enhanceAndSave({
    required Uint8List imageBytes,
    required EnhancementMode mode,
    required bool isDocumentScan,
  }) async {
    try {
      final enhancedBytes = await ImageEnhancer.enhance(imageBytes, mode);
      final filePath = await _saveToLocal(enhancedBytes);
      final file = File(filePath);

      return Right(
        ProcessedImage(
          filePath: filePath,
          enhancementMode: mode.name,
          fileSize: file.lengthSync(),
          isDocumentScan: isDocumentScan,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Gagal memproses gambar: $e'));
    }
  }

  Future<String> _saveToLocal(Uint8List bytes) async {
    final cacheDir = await getApplicationCacheDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'scan_$timestamp.jpg';
    final filePath = '${cacheDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }
}
