import 'package:flutter/material.dart';

import 'package:kegiatin/presentation/widgets/custom_input_card.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

class EventTimeSection extends StatelessWidget {
  const EventTimeSection({
    super.key,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.onPickTanggal,
    required this.onPickJamMulai,
    required this.onPickJamSelesai,
  });

  final DateTime? tanggal;
  final TimeOfDay? jamMulai;
  final TimeOfDay? jamSelesai;
  final VoidCallback onPickTanggal;
  final VoidCallback onPickJamMulai;
  final VoidCallback onPickJamSelesai;

  String _formatTanggal(DateTime dt) {
    String p(int v) => v.toString().padLeft(2, '0');
    return '${p(dt.day)}/${p(dt.month)}/${dt.year}';
  }

  String _formatJam(TimeOfDay t) {
    String p(int v) => v.toString().padLeft(2, '0');
    return '${p(t.hour)}:${p(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: 'Waktu Kegiatan', icon: Icons.schedule_outlined),
        const SizedBox(height: 12),

        // Tanggal
        CustomInputCard(
          child: InkWell(
            onTap: onPickTanggal,
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  tanggal != null ? _formatTanggal(tanggal!) : 'Tanggal Kegiatan',
                  style: textTheme.bodyMedium?.copyWith(
                    color: tanggal != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Jam Mulai & Jam Selesai
        Row(
          children: [
            Expanded(
              child: CustomInputCard(
                child: InkWell(
                  onTap: onPickJamMulai,
                  child: Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        jamMulai != null ? _formatJam(jamMulai!) : 'Jam Mulai',
                        style: textTheme.bodyMedium?.copyWith(
                          color: jamMulai != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomInputCard(
                child: InkWell(
                  onTap: onPickJamSelesai,
                  child: Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        jamSelesai != null ? _formatJam(jamSelesai!) : 'Jam Selesai',
                        style: textTheme.bodyMedium?.copyWith(
                          color: jamSelesai != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
