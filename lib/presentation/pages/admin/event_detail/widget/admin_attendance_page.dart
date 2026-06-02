import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/utils/string_utils.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/session_status.dart';
import 'package:kegiatin/presentation/controllers/attendance/attendance_list_controller.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/pages/admin/widget/invite_member_sheet.dart';

class AdminAttendancePage extends ConsumerStatefulWidget {
  const AdminAttendancePage({super.key, required this.sessions, required this.eventId});

  final List<Session> sessions;
  final String eventId;

  @override
  ConsumerState<AdminAttendancePage> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends ConsumerState<AdminAttendancePage> {
  Session? _selectedSession;

  @override
  void initState() {
    super.initState();
    _selectedSession = _getDefaultSession(widget.sessions);
  }

  @override
  void didUpdateWidget(covariant AdminAttendancePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sessions != oldWidget.sessions) {
      if (_selectedSession == null || !widget.sessions.contains(_selectedSession)) {
        setState(() {
          _selectedSession = _getDefaultSession(widget.sessions);
        });
      }
    }
  }

  Session? _getDefaultSession(List<Session> sessions) {
    if (sessions.isEmpty) return null;

    // 1. Cari yang ONGOING paling baru (berdasarkan startTime/order tertinggi)
    final ongoingSessions = sessions.where((s) => s.status == SessionStatus.ongoing).toList();
    if (ongoingSessions.isNotEmpty) {
      ongoingSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      return ongoingSessions.first;
    }

    // 2. Cari yang COMPLETED paling baru
    final completedSessions = sessions.where((s) => s.status == SessionStatus.completed).toList();
    if (completedSessions.isNotEmpty) {
      completedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      return completedSessions.first;
    }

    // 3. Fallback ke sesi pertama (order terendah)
    final sorted = List<Session>.from(sessions)..sort((a, b) => a.order.compareTo(b.order));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final eventAsync = ref.watch(eventDetailControllerProvider(widget.eventId));
    final isInviteOnly = eventAsync.maybeWhen(
      data: (event) => event.visibility == EventVisibility.inviteOnly,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Kelola Kehadiran'),
        backgroundColor: colorScheme.surfaceContainer,
        actions: [
          if (isInviteOnly)
            IconButton(
              icon: const Icon(Icons.person_add_alt_rounded),
              tooltip: 'Undang Anggota',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => InviteMemberSheet(eventId: widget.eventId),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.sessions.isNotEmpty && widget.sessions.length > 1) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<Session>(
                  initialValue: _selectedSession,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Sesi',
                    border: InputBorder.none,
                  ),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.primary),
                  items: widget.sessions.map((session) {
                    return DropdownMenuItem<Session>(
                      value: session,
                      child: Text(
                        'Sesi ${session.order}: ${session.title}',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSession = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Hadir',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_selectedSession != null)
                      Text(
                        'Sesi ${_selectedSession!.order}',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.sessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Belum ada sesi',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else if (_selectedSession != null)
                  _SessionCard(session: _selectedSession!)
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Pilih sesi untuk melihat kehadiran',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final attendanceAsync = ref.watch(attendanceListControllerProvider(session.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.title,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        attendanceAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: colorScheme.error),
              const SizedBox(width: 6),
              Text(
                'Gagal memuat daftar hadir',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Belum ada presensi pada sesi ini',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }
            return Column(children: list.map((a) => _AttendanceRow(attendance: a)).toList());
          },
        ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.attendance});

  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (statusLabel, statusColor) = switch (attendance.status) {
      AttendanceStatus.present => ('Hadir', colorScheme.primary),
      AttendanceStatus.late => ('Terlambat', colorScheme.tertiary),
      AttendanceStatus.absent => ('Absen', colorScheme.error),
    };

    final checkedInLocal = attendance.checkedInAt.toLocal();
    final checkInTime =
        '${checkedInLocal.hour.toString().padLeft(2, '0')}:${checkedInLocal.minute.toString().padLeft(2, '0')}';

    final hasUser = attendance.user != null;
    final displayName = hasUser ? attendance.user!.displayName : 'User ID: ${attendance.userId}';
    final photoUrl = hasUser ? attendance.user!.photoUrl : null;
    final npa = hasUser ? attendance.user!.npa : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(ApiConstants.resolveImageUrl(photoUrl))
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Text(
                    StringUtils.initials(displayName),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (npa != null && npa.isNotEmpty) ...[
                      Text(
                        'NPA: $npa • ',
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                    Text(
                      'Check-in: $checkInTime',
                      style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
        ],
      ),
    );
  }
}
