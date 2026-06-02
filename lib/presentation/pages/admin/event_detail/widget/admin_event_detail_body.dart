import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/archive/delete_archive_controller.dart';
import 'package:kegiatin/presentation/controllers/archive/session_archives_controller.dart';
import 'package:kegiatin/presentation/controllers/attendance/attendance_list_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/event_rsvp_list_controller.dart';
import 'package:kegiatin/presentation/pages/admin/event_detail/widget/admin_attendance_page.dart';
import 'package:kegiatin/presentation/pages/admin/event_detail/widget/admin_participants_page.dart';
import 'package:kegiatin/presentation/pages/admin/event_detail/widget/session_management_section.dart';
import 'package:kegiatin/presentation/pages/admin/widget/upload_materi_bottom_sheet.dart';
import 'package:kegiatin/presentation/pages/fullscreen_image_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminEventDetailBody extends ConsumerWidget {
  const AdminEventDetailBody({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasBanner = event.imageUrl != null && event.imageUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (hasBanner) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenImagePage(imageUrl: event.imageUrl!),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Image.network(
                          ApiConstants.resolveImageUrl(event.imageUrl!),
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fullscreen, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Perbesar',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                Text('Detail', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
          if (event.status == EventStatus.ongoing || event.status == EventStatus.completed) ...[
            _AttendanceSummaryCard(sessions: event.sessions, eventId: event.id),
            const SizedBox(height: 16),
            _ParticipantsSummaryCard(eventId: event.id),
            const SizedBox(height: 16),
          ] else if (event.status == EventStatus.draft || event.status == EventStatus.published || event.status == EventStatus.cancelled) ...[
            _ParticipantsSummaryCard(eventId: event.id),
            const SizedBox(height: 16),
          ],
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
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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
            onPressed: () async {
              final uri = Uri.parse(archive.fileUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 16, color: colorScheme.error),
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Hapus Materi'),
                  content: Text('Apakah Anda yakin ingin menghapus materi "${archive.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(deleteArchiveControllerProvider.notifier).delete(archive.id);
                ref.invalidate(sessionArchivesControllerProvider(archive.sessionId));
              }
            },
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
    final rsvpsAsync = ref.watch(eventRsvpListControllerProvider(eventId));
    final totalRsvp = rsvpsAsync.asData?.value.total ?? 0;

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
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            ...sessions.map((s) => _SessionSummaryRow(session: s, totalRsvp: totalRsvp)),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: () => _openAttendancePage(context),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Kelola Kehadiran'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
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
  const _SessionSummaryRow({required this.session, required this.totalRsvp});

  final Session session;
  final int totalRsvp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final attendanceAsync = ref.watch(attendanceListControllerProvider(session.id));

    final list = attendanceAsync.asData?.value ?? [];
    final hadir = list.where((a) => a.status == AttendanceStatus.present).length;
    final terlambat = list.where((a) => a.status == AttendanceStatus.late).length;
    final totalHadir = hadir + terlambat;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalHadir / $totalRsvp',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$hadir hadir',
                style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              if (terlambat > 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.outlineVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 10, color: colorScheme.tertiary),
                const SizedBox(width: 2),
                Text(
                  '$terlambat terlambat',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.tertiary),
                ),
              ],
            ],
          ),
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
    final total = rsvpsAsync.asData?.value.total ?? 0;
    final list = rsvpsAsync.asData?.value.data ?? [];

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
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            Text(
              'Belum ada peserta terdaftar',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            )
          else ...[
            Row(
              children: [
                SizedBox(
                  height: 32,
                  width: (list.take(5).length * 20.0) + 12.0,
                  child: Stack(
                    children: List.generate(
                      list.take(5).length,
                      (index) {
                        final user = list[index].user;
                        return Positioned(
                          left: index * 20.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: colorScheme.primaryContainer,
                              backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                  ? NetworkImage(ApiConstants.resolveImageUrl(user.photoUrl!))
                                  : null,
                              child: user.photoUrl == null || user.photoUrl!.isEmpty
                                  ? Text(
                                      (user.displayName.isNotEmpty ? user.displayName[0] : '?').toUpperCase(),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    list.length > 5
                        ? '${list.take(3).map((e) => e.user.displayName.split(' ').first).join(', ')}, dan ${total - 3} lainnya'
                        : list.map((e) => e.user.displayName.split(' ').first).join(', '),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$total peserta terdaftar',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: () => _openParticipantsPage(context),
              icon: const Icon(Icons.people_outline),
              label: const Text('Kelola Peserta'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
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
