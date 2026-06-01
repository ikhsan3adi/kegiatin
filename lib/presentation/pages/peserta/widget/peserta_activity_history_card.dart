import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/utils/date_formatter.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/controllers/archive/session_archives_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class PesertaActivityHistoryCard extends ConsumerStatefulWidget {
  const PesertaActivityHistoryCard({super.key, required this.record});

  final ActivityRecord record;

  @override
  ConsumerState<PesertaActivityHistoryCard> createState() => _PesertaActivityHistoryCardState();
}

class _PesertaActivityHistoryCardState extends ConsumerState<PesertaActivityHistoryCard> {
  bool _isExpanded = false;

  String _formatDateRange(List<SessionAttendance> sessions) {
    if (sessions.isEmpty) return 'Waktu belum ditentukan';
    final first = sessions.first.session.startTime;
    final last = sessions.last.session.startTime;

    if (sessions.length == 1) {
      final end = sessions.first.session.endTime;
      return '${first.day} ${DateFormatter.abbreviatedMonths[first.month - 1]} ${first.year}, '
          '${first.hour.toString().padLeft(2, '0')}:${first.minute.toString().padLeft(2, '0')} - '
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    }

    return '${first.day} ${DateFormatter.abbreviatedMonths[first.month - 1]} ${first.year} - '
        '${last.day} ${DateFormatter.abbreviatedMonths[last.month - 1]} ${last.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    return DateFormatter.formatDateShort(dt);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalSessions = widget.record.attendancePerSession.length;
    final attendedCount = widget.record.attendancePerSession
        .where((a) => a.status == AttendanceStatus.present || a.status == AttendanceStatus.late)
        .length;

    final firstSessionAtt = widget.record.attendancePerSession.isNotEmpty
        ? widget.record.attendancePerSession.first
        : null;
    final isSinglePresentOrLate =
        firstSessionAtt != null &&
        (firstSessionAtt.status == AttendanceStatus.present ||
            firstSessionAtt.status == AttendanceStatus.late);

    final progress = totalSessions > 0 ? (attendedCount / totalSessions) : 0.0;
    final percentText = '${(progress * 100).toInt()}%';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Badge(
                      label: widget.record.event.type == EventType.series ? 'Rutin' : 'Tunggal',
                      backgroundColor: widget.record.event.type == EventType.series
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                      textColor: widget.record.event.type == EventType.series
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSecondaryContainer,
                    ),
                    Text(
                      '$attendedCount / $totalSessions Sesi',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.record.event.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDateRange(widget.record.attendancePerSession),
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.record.event.location,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Attendance linear progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress Kehadiran',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      percentText,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    color: colorScheme.primary,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Expandable divider & label
          if (widget.record.event.type == EventType.series) ...[
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Sembunyikan Sesi' : 'Lihat Detail Sesi',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (_isExpanded && widget.record.event.type == EventType.series) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
              child: Column(
                children: widget.record.attendancePerSession.map((sessAtt) {
                  final status = sessAtt.status;
                  final timeStr = sessAtt.checkedInAt != null
                      ? _formatTime(sessAtt.checkedInAt!)
                      : null;

                  Color statusColor;
                  String statusLabel;

                  switch (status) {
                    case AttendanceStatus.present:
                      statusColor = colorScheme.primary;
                      statusLabel = timeStr != null ? 'Hadir ($timeStr)' : 'Hadir';
                      break;
                    case AttendanceStatus.late:
                      statusColor = colorScheme.tertiary;
                      statusLabel = timeStr != null ? 'Terlambat ($timeStr)' : 'Terlambat';
                      break;
                    case AttendanceStatus.absent:
                      statusColor = colorScheme.error;
                      statusLabel = 'Absen';
                      break;
                    case null:
                      statusColor = colorScheme.onSurfaceVariant;
                      statusLabel = 'Belum Mulai';
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sessAtt.session.title,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(sessAtt.session.startTime),
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (status == AttendanceStatus.present ||
                            status == AttendanceStatus.late) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.folder_open_outlined,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (_) => _MateriBottomSheet(session: sessAtt.session),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (widget.record.event.type == EventType.single && isSinglePresentOrLate) ...[
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => _MateriBottomSheet(session: firstSessionAtt.session),
                );
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_outlined, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Materi Kegiatan',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MateriBottomSheet extends ConsumerWidget {
  const _MateriBottomSheet({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final archiveAsync = ref.watch(sessionArchivesControllerProvider(session.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Materi: ${session.title}',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          archiveAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                const SizedBox(width: 6),
                Text(
                  'Gagal memuat materi',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ],
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada materi untuk sesi ini',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return Column(
                children: list.map((a) {
                  return ListTile(
                    leading: Icon(Icons.description_outlined, color: colorScheme.primary),
                    title: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Icon(Icons.open_in_new, size: 16, color: colorScheme.primary),
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      final uri = Uri.parse(a.fileUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.backgroundColor, required this.textColor});

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
