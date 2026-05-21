import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  } else {
    captureResult = await repository.capturePhoto();
  }

  if (captureResult == null || !context.mounted) return null;

  final selectedMode = await EnhancementPreview.show(context, imageBytes: captureResult.imageBytes);

  if (selectedMode == null || !context.mounted) return null;

  final result = await repository.enhanceAndSave(
    imageBytes: captureResult.imageBytes,
    mode: selectedMode,
    isDocumentScan: mode == CameraMode.document,
  );

  return result.fold((_) => null, (processed) => processed);
}
