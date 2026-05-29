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
  static void showError(BuildContext context, String message, {String title = 'Terjadi Kesalahan'}) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      title: title,
      message: message,
      icon: Icons.close,
      typeColor: colorScheme.error,
    );
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
                  margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Colored top border
                      Container(
                        height: 4,
                        width: double.infinity,
                        color: typeColor,
                      ),
                      Stack(
                        children: [
                          // Close button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.close, size: 20, color: colorScheme.onSurfaceVariant),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: dismiss,
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Circular Icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: typeColor, width: 2),
                                  ),
                                  child: Icon(icon, color: typeColor, size: 28),
                                ),
                                const SizedBox(height: 20),
                                // Title
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Message
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Action Button
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.onSurface,
                                      foregroundColor: colorScheme.surface,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: dismiss,
                                    child: const Text(
                                      'Tutup',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
