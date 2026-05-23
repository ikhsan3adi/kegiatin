import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/archive/session_archives_controller.dart';
import 'package:kegiatin/presentation/controllers/attendance/attendance_list_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/event_rsvp_list_controller.dart';
import 'package:kegiatin/presentation/pages/admin/event_detail/widget/admin_attendance_page.dart';
import 'package:kegiatin/presentation/pages/admin/event_detail/widget/admin_participants_page.dart';
import 'package:kegiatin/presentation/pages/admin/event_detail/widget/session_management_section.dart';
import 'package:kegiatin/presentation/pages/admin/widget/invite_member_sheet.dart';
import 'package:kegiatin/presentation/pages/admin/widget/upload_materi_bottom_sheet.dart';

class AdminEventDetailBody extends ConsumerWidget {
  const AdminEventDetailBody({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      'Deskripsi Kegiatan',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detail', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Visibilitas',
                  value: event.visibility == EventVisibility.open ? 'Publik' : 'Internal',
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Tipe Kegiatan',
                  value: event.type == EventType.series ? 'Rutin' : 'Tunggal',
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'Narahubung', value: event.contactPerson),
                if (event.visibility == EventVisibility.inviteOnly) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (_) => InviteMemberSheet(eventId: event.id),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                      label: const Text('Undang Anggota'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (event.type == EventType.series) ...[
            SessionManagementSection(event: event),
            const SizedBox(height: 16),
          ],
          _MaterialSection(event: event),
          const SizedBox(height: 16),
          _AttendanceSummaryCard(sessions: event.sessions, eventId: event.id),
          const SizedBox(height: 16),
          _ParticipantsSummaryCard(eventId: event.id),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MaterialSection extends ConsumerWidget {
  const _MaterialSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_copy_outlined, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(
                'Materi Kegiatan',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (event.sessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Tidak ada sesi',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...event.sessions.map((s) => _SessionArchiveSection(session: s)),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => UploadMateriBottomSheet(event: event),
                );
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Unggah Materi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionArchiveSection extends ConsumerWidget {
  const _SessionArchiveSection({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final archiveAsync = ref.watch(sessionArchivesControllerProvider(session.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(session.title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          archiveAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                const SizedBox(width: 6),
                Text(
                  'Gagal memuat',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ],
            ),
            data: (list) {
              if (list.isEmpty) {
                return Text(
                  'Belum ada materi',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                );
              }
              return Column(children: list.map((a) => _ArchiveRow(archive: a)).toList());
            },
          ),
        ],
      ),
    );
  }
}

class _ArchiveRow extends ConsumerWidget {
  const _ArchiveRow({required this.archive});

  final ArchiveItem archive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              archive.title,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.open_in_new, size: 16, color: colorScheme.primary),
            visualDensity: VisualDensity.compact,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 16, color: colorScheme.error),
            visualDensity: VisualDensity.compact,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends ConsumerWidget {
  const _AttendanceSummaryCard({required this.sessions, required this.eventId});

  final List<Session> sessions;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(
                'Daftar Hadir',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada sesi',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...sessions.map((s) => _SessionSummaryRow(session: s)),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => _openAttendancePage(context),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Kelola Kehadiran'),
            ),
          ),
        ],
      ),
    );
  }

  void _openAttendancePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAttendancePage(sessions: sessions, eventId: eventId),
      ),
    );
  }
}

class _SessionSummaryRow extends ConsumerWidget {
  const _SessionSummaryRow({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final attendanceAsync = ref.watch(attendanceListControllerProvider(session.id));

    final list = attendanceAsync.asData?.value ?? [];
    final total = list.length;
    final hadir = list.where((a) => a.status == AttendanceStatus.present).length;
    final terlambat = list.where((a) => a.status == AttendanceStatus.late).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              session.title,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text('$hadir/$total', style: textTheme.labelSmall?.copyWith(color: colorScheme.primary)),
          if (terlambat > 0) ...[
            const SizedBox(width: 6),
            Icon(Icons.access_time, size: 12, color: colorScheme.tertiary),
            const SizedBox(width: 2),
            Text('$terlambat', style: textTheme.labelSmall?.copyWith(color: colorScheme.tertiary)),
          ],
        ],
      ),
    );
  }
}

class _ParticipantsSummaryCard extends ConsumerWidget {
  const _ParticipantsSummaryCard({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rsvpsAsync = ref.watch(eventRsvpListControllerProvider(eventId));
    final total = rsvpsAsync.asData?.value.data.length ?? 0;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt_outlined, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(
                'Peserta Terdaftar',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$total peserta',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => _openParticipantsPage(context),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Kelola Peserta'),
            ),
          ),
        ],
      ),
    );
  }

  void _openParticipantsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminParticipantsPage(eventId: eventId)),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
