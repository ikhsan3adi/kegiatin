import 'package:flutter/material.dart';

/// Label judul section form dengan accent bar vertikal di kiri.
///
/// [icon] opsional — ditampilkan di antara accent bar dan teks.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        if (icon != null) ...[
          Icon(icon, size: 15, color: colorScheme.primary),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
