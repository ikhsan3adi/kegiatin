import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? valueColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.valueColor,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15), width: 0),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 8),

            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: labelColor ?? colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
