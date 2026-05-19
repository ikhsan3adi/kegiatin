import 'package:flutter/material.dart';
import 'package:kegiatin/presentation/pages/admin/widget/upload_materi_bottom_sheet.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class AdminMateriPage extends StatelessWidget {
  const AdminMateriPage({super.key});

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const UploadMateriBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        KegiatinAppBar(
          height: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Materi',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola materi kegiatan',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Konten kosong (belum ada backend materi)
        Expanded(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 72,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada materi',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk tombol di bawah untuk mengunggah\nmateri kegiatan.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // FAB di dalam Stack agar tidak bertabrakan dengan BottomNavBar
              Positioned(
                right: 24,
                bottom: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'fab_tambah_materi',
                  onPressed: () => _showUploadSheet(context),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  icon: const Icon(Icons.add),
                  label: const Text('Unggah Materi'),
                  elevation: 4.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
