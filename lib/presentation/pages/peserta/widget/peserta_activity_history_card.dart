import 'package:flutter/material.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';

class PesertaActivityHistoryCard extends StatelessWidget {
  const PesertaActivityHistoryCard({super.key, required this.record});

  final ActivityRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalSessions = record.attendancePerSession.length;
    final attendedCount = record.attendancePerSession
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final lateCount = record.attendancePerSession
        .where((a) => a.status == AttendanceStatus.late)
        .length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.event.title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Badge(label: '$attendedCount Hadir', color: colorScheme.primary),
              const SizedBox(width: 8),
              if (lateCount > 0) ...[
                _Badge(label: '$lateCount Terlambat', color: colorScheme.tertiary),
                const SizedBox(width: 8),
              ],
              _Badge(label: '$totalSessions Sesi', color: colorScheme.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
