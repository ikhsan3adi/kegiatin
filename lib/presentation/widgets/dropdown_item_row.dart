import 'package:flutter/material.dart';

/// Baris item dropdown dengan icon berwarna di kiri dan label teks.
///
/// Gunakan widget ini hanya di dalam [DropdownMenuItem.child].
/// Untuk tampilan nilai terpilih di field, gunakan [selectedItemBuilder]
/// pada [DropdownButtonFormField] agar icon tidak ganda.
class DropdownItemRow extends StatelessWidget {
  const DropdownItemRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.textStyle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(label, style: textStyle),
      ],
    );
  }
}
