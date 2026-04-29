import 'package:flutter/material.dart';
import 'package:kegiatin/core/theme/custom.dart';

/// Template AppBar melengkung (curved) dengan gradient warna tema.
///
/// Hanya menyediakan container visual (gradient, border radius, shadow).
/// Konten di dalamnya sepenuhnya dikontrol via parameter [child].
/// Digunakan di semua halaman — Beranda, Kegiatan, Profil, Pengaturan, dll.
class KegiatinAppBar extends StatelessWidget {
  const KegiatinAppBar({super.key, required this.child, this.padding});

  /// Konten yang ditampilkan di dalam container AppBar.
  final Widget child;

  /// Padding kustom. Default: `EdgeInsets.fromLTRB(20, 12, 20, 24)`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [KegiatinCustomTheme.appBarTop, KegiatinCustomTheme.appBarBottom],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SizedBox(
            height: 140,
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    );
  }
}
