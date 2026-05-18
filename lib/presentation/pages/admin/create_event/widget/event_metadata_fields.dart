import 'package:flutter/material.dart';

import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/widgets/custom_input_card.dart';
import 'package:kegiatin/presentation/widgets/dropdown_item_row.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

class EventMetadataFields extends StatelessWidget {
  const EventMetadataFields({
    super.key,
    required this.lokasiController,
    required this.narahubungController,
    required this.visibilitas,
    required this.onVisibilitasChanged,
    required this.labelVisibilitas,
  });

  final TextEditingController lokasiController;
  final TextEditingController narahubungController;
  final EventVisibility? visibilitas;
  final ValueChanged<EventVisibility?> onVisibilitasChanged;
  final String Function(EventVisibility) labelVisibilitas;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: 'Lokasi & Kontak', icon: Icons.place_outlined),
        const SizedBox(height: 12),

        // Lokasi
        CustomInputCard(
          child: TextFormField(
            controller: lokasiController,
            style: textTheme.bodyMedium,
            decoration:
                InputDecoration.collapsed(
                  hintText: 'Lokasi Pelaksanaan',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ).copyWith(
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: colorScheme.tertiary,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                ),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
        ),
        const SizedBox(height: 8),

        // Narahubung
        CustomInputCard(
          child: TextFormField(
            controller: narahubungController,
            style: textTheme.bodyMedium,
            decoration:
                InputDecoration.collapsed(
                  hintText: 'Narahubung',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ).copyWith(
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: colorScheme.secondary,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                ),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
        ),
        const SizedBox(height: 20),

        // Pengaturan
        const SectionLabel(label: 'Pengaturan', icon: Icons.tune_rounded),
        const SizedBox(height: 12),

        // Visibilitas
        CustomInputCard(
          child: DropdownButtonFormField<EventVisibility>(
            initialValue: visibilitas,
            isExpanded: true,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration.collapsed(
              hintText: 'Visibilitas',
              hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            hint: Text(
              'Visibilitas',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            items: EventVisibility.values
                .map(
                  (vis) => DropdownMenuItem(
                    value: vis,
                    child: Builder(
                      builder: (ctx) {
                        final cs = Theme.of(ctx).colorScheme;
                        final tt = Theme.of(ctx).textTheme;
                        return DropdownItemRow(
                          icon: vis == EventVisibility.open
                              ? Icons.public_rounded
                              : Icons.lock_outline_rounded,
                          iconColor: vis == EventVisibility.open ? cs.tertiary : cs.secondary,
                          label: labelVisibilitas(vis),
                          textStyle: tt.bodyMedium,
                        );
                      },
                    ),
                  ),
                )
                .toList(),
            onChanged: onVisibilitasChanged,
            selectedItemBuilder: (ctx) {
              final tt = Theme.of(ctx).textTheme;
              final cs = Theme.of(ctx).colorScheme;
              return EventVisibility.values
                  .map(
                    (vis) => Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownItemRow(
                        icon: vis == EventVisibility.open
                            ? Icons.public_rounded
                            : Icons.lock_outline_rounded,
                        iconColor: vis == EventVisibility.open ? cs.tertiary : cs.secondary,
                        label: labelVisibilitas(vis),
                        textStyle: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                    ),
                  )
                  .toList();
            },
            validator: (v) => v == null ? 'Wajib dipilih' : null,
          ),
        ),
      ],
    );
  }
}
