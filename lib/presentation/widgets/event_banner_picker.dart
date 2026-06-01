import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:kegiatin/presentation/widgets/smart_camera_launcher.dart';

class EventBannerPicker extends ConsumerWidget {
  final String? currentImageUrl;
  final ValueChanged<String> onImagePicked;
  final VoidCallback onRemove;

  const EventBannerPicker({
    super.key,
    this.currentImageUrl,
    required this.onImagePicked,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentImageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  ApiConstants.resolveImageUrl(currentImageUrl!),
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: colorScheme.scrim.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close, color: colorScheme.onInverseSurface, size: 18),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: colorScheme.scrim.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _pickBanner(context, ref),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: colorScheme.onInverseSurface, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Ganti Foto',
                              style: TextStyle(color: colorScheme.onInverseSurface, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          InkWell(
            onTap: () => _pickBanner(context, ref),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Tambah Banner Kegiatan',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload Dari Galeri / Kamera',
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickBanner(BuildContext context, WidgetRef ref) async {
    final CameraMode? selectedMode = await showModalBottomSheet<CameraMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        final localScheme = Theme.of(ctx).colorScheme;
        final localText = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Metode Pengambilan Banner',
                style: localText.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: localScheme.primary),
                title: const Text('Pilih dari Galeri (Upload File)'),
                onTap: () => Navigator.pop(ctx, CameraMode.gallery),
              ),
              ListTile(
                leading: Icon(Icons.document_scanner_outlined, color: localScheme.primary),
                title: const Text('Kamera Cerdas (Smart Camera)'),
                onTap: () => Navigator.pop(ctx, CameraMode.document),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: localScheme.primary),
                title: const Text('Kamera Biasa'),
                onTap: () => Navigator.pop(ctx, CameraMode.photo),
              ),
            ],
          ),
        );
      },
    );

    if (selectedMode == null || !context.mounted) return;

    try {
      final result = await launchSmartCamera(context, ref, mode: selectedMode, cropImage: true);
      if (result == null || !context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_upload_outlined, color: KegiatinCustomTheme.onGradient, size: 18),
              SizedBox(width: 8),
              Text('Mengupload banner...'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      final uploadRepo = ref.read(uploadsRemoteDataSourceProvider);
      final url = await uploadRepo.uploadImage(result.filePath);
      if (context.mounted) onImagePicked(url);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupload banner: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
