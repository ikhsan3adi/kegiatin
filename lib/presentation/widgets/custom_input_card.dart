import 'package:flutter/material.dart';

/// background surface, border radius 12, dan border tipis.
class CustomInputCard extends StatelessWidget {
  const CustomInputCard({super.key, required this.child});

  /// Widget input yang dibungkus oleh card ini.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}
