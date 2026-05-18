import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kegiatin/presentation/widgets/custom_input_card.dart';
import 'package:kegiatin/presentation/widgets/dropdown_item_row.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

import '../../create_event_sessions.dart';
import '../shared.dart';

class EventSeriesSettings extends StatelessWidget {
  const EventSeriesSettings({
    super.key,
    required this.polaPengulangan,
    required this.onPolaPengulanganChanged,
    required this.jumlahPertemuanController,
    required this.onJumlahPertemuanChanged,
    required this.generatedSessions,
    required this.isCustom,
    required this.onEditSession,
    required this.formatDateShort,
    required this.kMaxSesi,
  });

  final RepeatPattern? polaPengulangan;
  final ValueChanged<RepeatPattern?> onPolaPengulanganChanged;
  final TextEditingController jumlahPertemuanController;
  final VoidCallback onJumlahPertemuanChanged;
  final List<DateTime> generatedSessions;
  final bool isCustom;
  final void Function(int index) onEditSession;
  final String Function(DateTime) formatDateShort;
  final int kMaxSesi;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionLabel(label: 'Pengaturan Series', icon: Icons.repeat_rounded),
        const SizedBox(height: 12),

        // Pola Pengulangan
        CustomInputCard(
          child: DropdownButtonFormField<RepeatPattern>(
            initialValue: polaPengulangan,
            isExpanded: true,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration.collapsed(
              hintText: 'Pola Pengulangan',
              hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            hint: Text(
              'Pola Pengulangan',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            items: [
              for (final p in RepeatPattern.values)
                DropdownMenuItem(
                  value: p,
                  child: Builder(
                    builder: (ctx) {
                      final cs = Theme.of(ctx).colorScheme;
                      final tt = Theme.of(ctx).textTheme;
                      return DropdownItemRow(
                        icon: switch (p) {
                          RepeatPattern.mingguan => Icons.calendar_view_week_outlined,
                          RepeatPattern.bulanan => Icons.calendar_month_outlined,
                          RepeatPattern.custom => Icons.tune_rounded,
                        },
                        iconColor: switch (p) {
                          RepeatPattern.mingguan => cs.primary,
                          RepeatPattern.bulanan => cs.tertiary,
                          RepeatPattern.custom => cs.secondary,
                        },
                        label: switch (p) {
                          RepeatPattern.mingguan => 'Mingguan',
                          RepeatPattern.bulanan => 'Bulanan',
                          RepeatPattern.custom => 'Custom',
                        },
                        textStyle: tt.bodyMedium,
                      );
                    },
                  ),
                ),
            ],
            onChanged: onPolaPengulanganChanged,
            selectedItemBuilder: (ctx) {
              final tt = Theme.of(ctx).textTheme;
              final cs = Theme.of(ctx).colorScheme;
              return RepeatPattern.values
                  .map(
                    (p) => Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownItemRow(
                        icon: switch (p) {
                          RepeatPattern.mingguan => Icons.calendar_view_week_outlined,
                          RepeatPattern.bulanan => Icons.calendar_month_outlined,
                          RepeatPattern.custom => Icons.tune_rounded,
                        },
                        iconColor: switch (p) {
                          RepeatPattern.mingguan => cs.primary,
                          RepeatPattern.bulanan => cs.tertiary,
                          RepeatPattern.custom => cs.secondary,
                        },
                        label: switch (p) {
                          RepeatPattern.mingguan => 'Mingguan',
                          RepeatPattern.bulanan => 'Bulanan',
                          RepeatPattern.custom => 'Custom',
                        },
                        textStyle: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                    ),
                  )
                  .toList();
            },
            validator: (v) => v == null ? 'Wajib dipilih' : null,
          ),
        ),
        const SizedBox(height: 8),

        // Jumlah Pertemuan
        CustomInputCard(
          child: TextFormField(
            controller: jumlahPertemuanController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: textTheme.bodyMedium,
            decoration:
                InputDecoration.collapsed(
                  hintText: 'Jumlah Pertemuan (maks. $kMaxSesi)',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ).copyWith(
                  prefixIcon: Icon(
                    Icons.format_list_numbered_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                ),
            onChanged: (_) => onJumlahPertemuanChanged(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Wajib diisi untuk Series';
              }
              final n = int.tryParse(v.trim());
              if (n == null || n <= 0) {
                return 'Minimal 1 pertemuan';
              }
              return null;
            },
          ),
        ),

        // Jadwal sesi ter-generate
        if (generatedSessions.isNotEmpty) ...[
          const SizedBox(height: 12),
          SessionListHeader(count: generatedSessions.length, isCustom: isCustom),
          const SizedBox(height: 8),
          SessionDateGrid(
            sessions: generatedSessions,
            isCustom: isCustom,
            onEdit: onEditSession,
            formatDate: formatDateShort,
          ),
        ],
      ],
    );
  }
}
