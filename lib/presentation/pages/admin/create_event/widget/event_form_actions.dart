import 'package:flutter/material.dart';

import 'package:kegiatin/core/theme/custom.dart';

class EventFormActions extends StatelessWidget {
  const EventFormActions({super.key, required this.isLoading, required this.onSimpan});

  final bool isLoading;
  final VoidCallback onSimpan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: isLoading ? null : onSimpan,
        style: FilledButton.styleFrom(
          backgroundColor: KegiatinCustomTheme.appBarTop,
          disabledBackgroundColor: KegiatinCustomTheme.appBarTop.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: KegiatinCustomTheme.onGradient,
                ),
              )
            : Text(
                'Simpan Kegiatan',
                style: textTheme.labelLarge?.copyWith(
                  color: KegiatinCustomTheme.onGradient,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
