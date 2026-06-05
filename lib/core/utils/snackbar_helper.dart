import 'package:flutter/material.dart';
import 'package:kegiatin/core/theme/custom.dart';

/// Centralized helper for showing consistent feedback snackbars.
///
/// All snackbars are floating, rounded, and use the app's design tokens.
/// The design resembles a popup alert with a colored top border and a circular icon.
abstract final class SnackBarHelper {
  static OverlayEntry? _currentOverlay;

  /// Shows a success snackbar with a check icon.
  static void showSuccess(BuildContext context, String message, {String title = 'Berhasil'}) {
    _show(
      context,
      title: title,
      message: message,
      icon: Icons.check,
      typeColor: KegiatinCustomTheme.snackbarSuccess,
    );
  }

  /// Shows an error snackbar using the theme's error color.
  static void showError(
    BuildContext context,
    String message, {
    String title = 'Terjadi Kesalahan',
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(context, title: title, message: message, icon: Icons.close, typeColor: colorScheme.error);
  }

  /// Shows a warning snackbar (e.g. missing required selection).
  static void showWarning(BuildContext context, String message, {String title = 'Perhatian'}) {
    _show(
      context,
      title: title,
      message: message,
      icon: Icons.priority_high,
      typeColor: Colors.orange,
    );
  }

  /// Shows a neutral info snackbar (e.g. upload in progress).
  static void showInfo(
    BuildContext context,
    String message, {
    String title = 'Informasi',
    Duration duration = const Duration(seconds: 3),
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      title: title,
      message: message,
      icon: Icons.info_outline,
      typeColor: colorScheme.secondary,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color typeColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    // Hapus overlay sebelumnya jika masih ada
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    late OverlayEntry entry;

    void dismiss() {
      if (entry.mounted && _currentOverlay == entry) {
        entry.remove();
        _currentOverlay = null;
      }
    }

    entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: typeColor.withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Tombol Close (X)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          icon: Icon(Icons.close, size: 22, color: colorScheme.onSurfaceVariant),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                            hoverColor: colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                          onPressed: dismiss,
                        ),
                      ),
                      // Konten Utama
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ikon dengan efek menyala (Glow)
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: typeColor.withValues(alpha: 0.2),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(icon, color: typeColor, size: 42),
                            ),
                            const SizedBox(height: 24),
                            // Judul (Bold)
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Pesan / Deskripsi
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Tombol Aksi Utama
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: typeColor,
                                  foregroundColor: KegiatinCustomTheme.onGradient,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: dismiss,
                                child: const Text(
                                  'Mengerti',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentOverlay = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      dismiss();
    });
  }
}
