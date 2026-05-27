import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:kegiatin/presentation/providers/pcd_providers.dart';
import 'package:kegiatin/presentation/widgets/enhancement_preview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<ProcessedImage?> launchSmartCamera(
  BuildContext context,
  WidgetRef ref, {
  CameraMode mode = CameraMode.document,
  bool cropImage = false,
}) async {
  if (mode == CameraMode.photo) {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin kamera diperlukan untuk mode foto')));
      }
      return null;
    }
  }

  final repository = ref.read(pcdRepositoryProvider);

  CaptureResult? captureResult;
  if (mode == CameraMode.document) {
    captureResult = await repository.captureDocument();
  } else if (mode == CameraMode.photo) {
    captureResult = await repository.capturePhoto();
  } else {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) {
      captureResult = null;
    } else {
      final bytes = await File(picked.path).readAsBytes();
      captureResult = CaptureResult(imageBytes: bytes);
    }
  }

  if (captureResult == null || !context.mounted) return null;

  if (cropImage) {
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
        return null;
      }

      final croppedBytes = await croppedFile.readAsBytes();
      captureResult = CaptureResult(imageBytes: croppedBytes);
    } catch (e) {
      debugPrint('Error cropping image: $e');
    }
  }

  final finalResult = captureResult;
  if (finalResult == null || !context.mounted) return null;

  final defaultMode = mode == CameraMode.document
      ? EnhancementMode.original
      : EnhancementMode.auto;
  final selectedMode = await EnhancementPreview.show(
    context,
    imageBytes: finalResult.imageBytes,
    defaultMode: defaultMode,
  );

  if (selectedMode == null || !context.mounted) return null;

  final result = await repository.enhanceAndSave(
    imageBytes: finalResult.imageBytes,
    mode: selectedMode,
    isDocumentScan: mode == CameraMode.document,
  );

  return result.fold((_) => null, (processed) => processed);
}
