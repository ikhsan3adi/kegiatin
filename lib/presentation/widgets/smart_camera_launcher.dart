import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:kegiatin/presentation/providers/pcd_providers.dart';
import 'package:kegiatin/presentation/widgets/enhancement_preview.dart';
import 'package:permission_handler/permission_handler.dart';

Future<ProcessedImage?> launchSmartCamera(
  BuildContext context,
  WidgetRef ref, {
  CameraMode mode = CameraMode.document,
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

  final CaptureResult? captureResult;
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

  final defaultMode = mode == CameraMode.document
      ? EnhancementMode.original
      : EnhancementMode.enhanced;
  final selectedMode = await EnhancementPreview.show(
    context,
    imageBytes: captureResult.imageBytes,
    defaultMode: defaultMode,
  );

  if (selectedMode == null || !context.mounted) return null;

  final result = await repository.enhanceAndSave(
    imageBytes: captureResult.imageBytes,
    mode: selectedMode,
    isDocumentScan: mode == CameraMode.document,
  );

  return result.fold((_) => null, (processed) => processed);
}
