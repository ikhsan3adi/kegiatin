import 'package:flutter/material.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

/// Card pengaturan — menampilkan daftar menu aksi seperti "Edit Profil".
///
/// Bergaya identik dengan [ProfileCard] agar tampak konsisten di halaman profil.
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.items});

  /// Daftar item menu yang ditampilkan di dalam card.
  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
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
          const SectionLabel(label: 'Pengaturan'),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++) ...[
            _SettingsRow(item: items[i]),
            if (i < items.length - 1)
              Divider(
                height: 24,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
          ],
        ],
      ),
    );
  }
}

/// Data untuk satu item menu di dalam [SettingsCard].
class SettingsItem {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsItem({
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}

/// Satu baris item menu — ikon berwarna, label, subtitle opsional, dan chevron.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});

  final SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final iconColor = item.iconColor ?? colorScheme.primary;
    final iconBgColor = item.iconBgColor ?? colorScheme.primaryContainer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        item.subtitle!,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
