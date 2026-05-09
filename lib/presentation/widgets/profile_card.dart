import 'package:flutter/material.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

/// Card informasi kontak pengguna — menampilkan email dan tanggal bergabung.
///
/// Menerima parameter individual agar widget tetap reusable tanpa bergantung
/// pada entitas [User] secara langsung.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.email, required this.joinedAt});

  /// Alamat email pengguna.
  final String email;

  /// Tanggal pengguna pertama kali mendaftar.
  final DateTime joinedAt;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'Informasi Kontak'),
          const SizedBox(height: 16),
          _ContactRow(
            icon: Icons.email_outlined,
            iconColor: colorScheme.primary,
            iconBgColor: colorScheme.primaryContainer,
            label: 'Email',
            value: email,
          ),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.calendar_today_outlined,
            iconColor: colorScheme.error,
            iconBgColor: colorScheme.errorContainer,
            label: 'Tanggal Bergabung',
            value: _formatDate(joinedAt),
          ),
        ],
      ),
    );
  }

  /// Format [DateTime] ke string `dd-MM-yyyy`.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }
}

/// Satu baris item kontak — ikon berwarna, label kecil, dan nilai utama.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
