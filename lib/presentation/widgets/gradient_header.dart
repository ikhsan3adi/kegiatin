import 'package:flutter/material.dart';
import 'package:kegiatin/core/theme/custom.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({super.key, required this.onBack, required this.title, this.subtitle});

  /// Callback dipanggil saat tombol kembali ditekan.
  final VoidCallback onBack;

  /// Judul utama yang ditampilkan di header.
  final String title;

  /// Subjudul opsional di bawah judul.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [KegiatinCustomTheme.appBarTop, KegiatinCustomTheme.appBarBottom],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [BoxShadow(color: Color(0x4D0F3F7A), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Kembali',
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
