import 'package:flutter/material.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/attendance/my_attendance_controller.dart';
import 'package:kegiatin/presentation/controllers/archive/session_archives_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/create_rsvp_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/my_rsvp_controller.dart';
import 'package:kegiatin/presentation/pages/fullscreen_image_page.dart';
import 'package:kegiatin/presentation/pages/peserta/peserta_riwayat_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Konten scrollable halaman detail event peserta.
///
/// Menampilkan deskripsi, detail event, dan tombol aksi RSVP/QR
/// di bagian bawah scroll.
class PesertaEventDetailBody extends ConsumerWidget {
  const PesertaEventDetailBody({super.key, required this.event});

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
                              color: colorScheme.scrim.withValues(alpha: 0.54),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fullscreen,
                                  color: colorScheme.onInverseSurface,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Perbesar',
                                  style: TextStyle(
                                    color: colorScheme.onInverseSurface,
                                    fontSize: 10,
                                  ),
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MateriKegiatanCard(event: event),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: _PesertaActionButton(event: event),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tombol aksi RSVP / Lihat QR peserta.
///
/// Menampilkan state yang sesuai berdasarkan status RSVP dan status event.
class _PesertaActionButton extends ConsumerWidget {
  const _PesertaActionButton({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final myRsvpAsync = ref.watch(myRsvpControllerProvider);
    final createState = ref.watch(createRsvpControllerProvider);
    final myAttendanceAsync = ref.watch(myAttendanceControllerProvider);

    ref.listen<AsyncValue<dynamic>>(myRsvpControllerProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat status pendaftaran: $err'),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    ref.listen<AsyncValue<dynamic>>(myAttendanceControllerProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat status kehadiran: $err'),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    ref.listen<AsyncValue<dynamic>>(historyControllerProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat riwayat kegiatan: $err'),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    final isCreating = createState.isLoading;

    if (isCreating) {
      return _ActionChip(
        icon: Icons.hourglass_top,
        label: 'Mendaftar...',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        onTap: null,
      );
    }

    if (myRsvpAsync.isLoading ||
        myAttendanceAsync.isLoading ||
        ref.watch(historyControllerProvider).isLoading) {
      return _ActionChip(
        icon: Icons.hourglass_top,
        label: 'Memuat status...',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    if (myRsvpAsync.hasError ||
        myAttendanceAsync.hasError ||
        ref.watch(historyControllerProvider).hasError) {
      return _ActionChip(
        icon: Icons.error_outline,
        label: 'Gagal memuat status',
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
        onTap: () {
          ref.invalidate(myRsvpControllerProvider);
          ref.invalidate(myAttendanceControllerProvider);
          ref.invalidate(historyControllerProvider);
        },
      );
    }

    final alreadyRsvp = myRsvpAsync.value?.any((r) => r.eventId == event.id) ?? false;

    final historyList = ref.watch(historyControllerProvider).value ?? [];
    final historyRecord = historyList.cast<ActivityRecord?>().firstWhere(
      (r) => r?.event.id == event.id,
      orElse: () => null,
    );
    final historyAttended =
        historyRecord?.attendancePerSession.any(
          (sa) => sa.status == AttendanceStatus.present || sa.status == AttendanceStatus.late,
        ) ??
        false;

    final alreadyAttended =
        (myAttendanceAsync.value?.any((att) {
              return event.sessions.any((session) => att.sessionId == session.id) &&
                  (att.status == AttendanceStatus.present || att.status == AttendanceStatus.late);
            }) ??
            false) ||
        historyAttended;

    if (alreadyRsvp) {
      if (alreadyAttended) {
        return _ActionChip(
          icon: Icons.check_circle_outline,
          label: 'Sudah Hadir',
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: colorScheme.primary,
          onTap: () => context.go('/peserta/qr/${event.id}'),
        );
      }
      return _ActionChip(
        icon: Icons.qr_code_2,
        label: 'Lihat QR',
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        onTap: () => context.go('/peserta/qr/${event.id}'),
      );
    }

    if (event.status == EventStatus.completed) {
      return _ActionChip(
        icon: Icons.event_busy,
        label: 'Kegiatan Berakhir',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    if (event.status == EventStatus.ongoing) {
      return _ActionChip(
        icon: Icons.event_busy,
        label: 'Pendaftaran Ditutup',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    if (event.status == EventStatus.cancelled) {
      return _ActionChip(
        icon: Icons.cancel_outlined,
        label: 'Kegiatan Dibatalkan',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    if (event.status == EventStatus.draft) {
      return _ActionChip(
        icon: Icons.drafts_outlined,
        label: 'Belum Diterbitkan',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    if (isCreating) {
      return _ActionChip(
        icon: Icons.hourglass_top,
        label: 'Mendaftar...',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        onTap: null,
      );
    }

    if (myRsvpAsync.isLoading) {
      return _ActionChip(
        icon: Icons.assignment_outlined,
        label: 'Daftar Kegiatan',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        onTap: null,
      );
    }

    return _ActionChip(
      icon: Icons.assignment_outlined,
      label: 'Daftar Kegiatan',
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      onTap: () => _confirmRsvp(context, ref, event.id, event.title),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _confirmRsvp(BuildContext context, WidgetRef ref, String eventId, String eventTitle) {
  final colorScheme = Theme.of(context).colorScheme;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Konfirmasi RSVP'),
      content: Text(
        'Apakah Anda yakin ingin mendaftar ke kegiatan "$eventTitle"? Kuota Anda akan terpakai.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            ref.read(createRsvpControllerProvider.notifier).createRsvp(eventId);
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          child: const Text('Ya, Daftar'),
        ),
      ],
    ),
  );
}

class _MateriKegiatanCard extends ConsumerWidget {
  const _MateriKegiatanCard({required this.event});

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
            ...event.sessions.map((s) => _PesertaSessionArchiveSection(session: s)),
        ],
      ),
    );
  }
}

class _PesertaSessionArchiveSection extends ConsumerWidget {
  const _PesertaSessionArchiveSection({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final myAttendanceList = ref.watch(myAttendanceControllerProvider).value ?? [];
    final localAttendance = myAttendanceList.cast<Attendance?>().firstWhere(
      (a) => a?.sessionId == session.id,
      orElse: () => null,
    );

    final historyList = ref.watch(historyControllerProvider).value ?? [];
    final historyRecord = historyList.cast<ActivityRecord?>().firstWhere(
      (r) => r?.event.id == session.eventId,
      orElse: () => null,
    );
    final historySessionAttendance = historyRecord?.attendancePerSession
        .cast<SessionAttendance?>()
        .firstWhere((sa) => sa?.session.id == session.id, orElse: () => null);

    final isPresentOrLate =
        (localAttendance != null &&
            (localAttendance.status == AttendanceStatus.present ||
                localAttendance.status == AttendanceStatus.late)) ||
        (historySessionAttendance != null &&
            (historySessionAttendance.status == AttendanceStatus.present ||
                historySessionAttendance.status == AttendanceStatus.late));

    if (!isPresentOrLate) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.lock_outline, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Materi terkunci (Hadir untuk membuka)',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      );
    }

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
            error: (e, _) {
              final errorStr = e.toString();
              final isForbidden =
                  errorStr.contains('403') ||
                  errorStr.contains('ForbiddenException') ||
                  errorStr.contains('Akses materi');
              return Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                  const SizedBox(width: 6),
                  Text(
                    isForbidden ? 'Akses ditolak (Kehadiran belum terverifikasi)' : 'Gagal memuat',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                  ),
                ],
              );
            },
            data: (list) {
              if (list.isEmpty) {
                return Text(
                  'Belum ada materi',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                );
              }
              return Column(
                children: list.map((a) {
                  return _PesertaArchiveRow(archive: a, isAccessible: isPresentOrLate);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PesertaArchiveRow extends StatelessWidget {
  const _PesertaArchiveRow({required this.archive, required this.isAccessible});

  final ArchiveItem archive;
  final bool isAccessible;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          if (!isAccessible) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Akses materi hanya untuk peserta yang hadir/terlambat pada sesi ini',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          final uri = Uri.parse(archive.fileUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: isAccessible ? 1.0 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Icon(
                  isAccessible ? Icons.description_outlined : Icons.lock_outline_rounded,
                  size: 18,
                  color: isAccessible ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    archive.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: isAccessible ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isAccessible) Icon(Icons.open_in_new, size: 14, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
