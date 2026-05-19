import 'package:flutter/material.dart';

import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/widgets/custom_input_card.dart';
import 'package:kegiatin/presentation/widgets/dropdown_item_row.dart';

class EventTypeSelector extends StatelessWidget {
  const EventTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.labelTipe,
  });

  final EventType? value;
  final ValueChanged<EventType?> onChanged;
  final String Function(EventType) labelTipe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomInputCard(
      child: DropdownButtonFormField<EventType>(
        initialValue: value,
        isExpanded: true,
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration.collapsed(
          hintText: 'Jenis Kegiatan',
          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        hint: Text(
          'Jenis Kegiatan',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        items: EventType.values
            .map(
              (t) => DropdownMenuItem(
                value: t,
                child: Builder(
                  builder: (ctx) {
                    final cs = Theme.of(ctx).colorScheme;
                    final tt = Theme.of(ctx).textTheme;
                    return DropdownItemRow(
                      icon: t == EventType.single
                          ? Icons.event_outlined
                          : Icons.event_repeat_outlined,
                      iconColor: t == EventType.single ? cs.primary : cs.secondary,
                      label: labelTipe(t),
                      textStyle: tt.bodyMedium,
                    );
                  },
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        selectedItemBuilder: (ctx) {
          final tt = Theme.of(ctx).textTheme;
          final cs = Theme.of(ctx).colorScheme;
          return EventType.values
              .map(
                (t) => Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownItemRow(
                    icon: t == EventType.single
                        ? Icons.event_outlined
                        : Icons.event_repeat_outlined,
                    iconColor: t == EventType.single ? cs.primary : cs.secondary,
                    label: labelTipe(t),
                    textStyle: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
              )
              .toList();
        },
        validator: (v) => v == null ? 'Wajib dipilih' : null,
      ),
    );
  }
}
