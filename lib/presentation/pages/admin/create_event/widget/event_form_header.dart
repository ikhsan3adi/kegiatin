import 'package:flutter/material.dart';

import 'package:kegiatin/presentation/widgets/custom_input_card.dart';

class EventFormHeader extends StatelessWidget {
  const EventFormHeader({
    super.key,
    required this.namaController,
    required this.deskripsiController,
    this.typeSelector,
  });

  final TextEditingController namaController;
  final TextEditingController deskripsiController;

  /// Widget yang disisipkan di antara field Nama dan Deskripsi.
  final Widget? typeSelector;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        CustomInputCard(
          child: TextFormField(
            controller: namaController,
            style: textTheme.bodyMedium,
            decoration:
                InputDecoration.collapsed(
                  hintText: 'Nama Kegiatan',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ).copyWith(
                  prefixIcon: Icon(Icons.event_outlined, size: 18, color: colorScheme.primary),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                ),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
        ),
        if (typeSelector != null) ...[const SizedBox(height: 8), typeSelector!],
        const SizedBox(height: 8),
        CustomInputCard(
          child: TextFormField(
            controller: deskripsiController,
            maxLines: 3,
            style: textTheme.bodyMedium,
            decoration:
                InputDecoration.collapsed(
                  hintText: 'Deskripsi Kegiatan',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ).copyWith(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.notes_rounded, size: 18, color: colorScheme.tertiary),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
        ),
      ],
    );
  }
}
