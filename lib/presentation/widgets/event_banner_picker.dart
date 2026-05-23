import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentImageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Image.network(
                  currentImageUrl!,
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
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () => _pickBanner(context, ref),
          icon: Icon(Icons.camera_alt_outlined, size: 18, color: colorScheme.primary),
          label: Text(currentImageUrl == null ? 'Ambil Foto Banner' : 'Ganti Foto Banner'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickBanner(BuildContext context, WidgetRef ref) async {
    try {
      final result = await launchSmartCamera(context, ref, mode: CameraMode.photo);
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
