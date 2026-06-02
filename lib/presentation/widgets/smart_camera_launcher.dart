import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/core/utils/snackbar_helper.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:kegiatin/presentation/providers/pcd_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<List<ProcessedImage>> launchSmartCamera(
  BuildContext context,
  WidgetRef ref, {
  CameraMode mode = CameraMode.document,
  bool cropImage = false,
  int pageLimit = 1,
}) async {
  if (mode == CameraMode.photo) {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Izin kamera diperlukan untuk mode foto');
      }
      return [];
    }
  }

  final repository = ref.read(pcdRepositoryProvider);

  List<CaptureResult>? captureResults;
  if (mode == CameraMode.document) {
    captureResults = await repository.captureDocument(pageLimit: pageLimit);
  } else if (mode == CameraMode.photo) {
    final photoResult = await repository.capturePhoto();
    if (photoResult != null) {
      captureResults = [photoResult];
    }
  } else {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      captureResults = [CaptureResult(imageBytes: bytes)];
    }
  }

  if (captureResults == null || captureResults.isEmpty || !context.mounted) return [];

  if (cropImage && captureResults.isNotEmpty) {
    final captureResult = captureResults.first;
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/crop_temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(captureResult.imageBytes);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Gambar Banner',
            toolbarColor: colorScheme.primary,
            toolbarWidgetColor: colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
          ),
          IOSUiSettings(
            title: 'Potong Gambar Banner',
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
          ),
        ],
      );

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (croppedFile == null) {
        return [];
      }

      final croppedBytes = await croppedFile.readAsBytes();
      captureResults = [CaptureResult(imageBytes: croppedBytes)];
    } catch (e) {
      debugPrint('Error cropping image: $e');
    }
  }

  if (captureResults == null || captureResults.isEmpty || !context.mounted) return [];

  const selectedMode = EnhancementMode.original;
  final List<ProcessedImage> processedImages = [];

  if (captureResults.length > 1 && context.mounted) {
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memproses gambar...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  try {
    for (final captureResult in captureResults) {
      final result = await repository.enhanceAndSave(
        imageBytes: captureResult.imageBytes,
        mode: selectedMode,
        isDocumentScan: mode == CameraMode.document,
      );
      result.fold((_) => null, (processed) => processedImages.add(processed));
    }
  } finally {
    if (captureResults.length > 1 && context.mounted) {
      Navigator.pop(context);
    }
  }

  return processedImages;
}
