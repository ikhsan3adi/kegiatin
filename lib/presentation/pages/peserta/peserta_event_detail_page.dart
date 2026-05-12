import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/create_rsvp_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/my_rsvp_controller.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class PesertaEventDetailPage extends ConsumerWidget {
  const PesertaEventDetailPage({super.key, required this.eventId});

  /// UUID dari route `/peserta/event-detail/:eventId`.
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvent = ref.watch(eventDetailControllerProvider(eventId));

    return asyncEvent.when(
      loading: () => _pesertaDetailFallbackScaffold(
        context,
        const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _pesertaDetailFallbackScaffold(
        context,
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(eventDetailControllerProvider(eventId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (event) => _PesertaEventDetailContent(event: event),
    );
  }
}

Widget _pesertaDetailFallbackScaffold(BuildContext context, Widget body) {
  final colorScheme = Theme.of(context).colorScheme;
  return Scaffold(
    backgroundColor: colorScheme.surfaceContainerHighest,
    appBar: AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      backgroundColor: colorScheme.surfaceContainerHighest,
    ),
    body: body,
  );
}

class _PesertaEventDetailContent extends ConsumerWidget {
  const _PesertaEventDetailContent({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Listen untuk menampilkan snackbar saat RSVP selesai.
    ref.listen(createRsvpControllerProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mendaftar: $err'),
              backgroundColor: colorScheme.error,
            ),
          );
        },
        data: (rsvp) {
          if (rsvp != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Berhasil mendaftar ke kegiatan!'),
                backgroundColor: colorScheme.primary,
              ),
            );
          }
        },
      );
    });

    final firstSession = event.sessions.isNotEmpty ? event.sessions.first : null;
    final startTime = firstSession?.startTime;
    final dateStr = startTime != null
        ? "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} . ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"
        : 'Waktu belum ditentukan';

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          KegiatinAppBar(
            height: null,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: colorScheme.onPrimary, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(
                      text: _getStatusText(event.status),
                      backgroundColor: colorScheme.secondaryContainer,
                      textColor: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      text: event.type == EventType.series ? 'Rutin' : 'Tunggal',
                      backgroundColor: colorScheme.tertiaryContainer,
                      textColor: colorScheme.onTertiaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Info',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                        Text(
                          'Detail',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          'Visibilitas',
                          event.visibility == EventVisibility.open ? 'Publik' : 'Internal',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          'Tipe Kegiatan',
                          event.type == EventType.series ? 'Rutin' : 'Tunggal',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(context, 'Narahubung', event.contactPerson),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(context, ref),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getStatusText(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Akan Datang';
      case EventStatus.ongoing:
        return 'Berlangsung';
      case EventStatus.completed:
        return 'Selesai';
      case EventStatus.cancelled:
        return 'Batal';
    }
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Cek status RSVP dari cache (load async, default null = belum tahu).
    final myRsvpAsync = ref.watch(myRsvpControllerProvider);
    final createState = ref.watch(createRsvpControllerProvider);

    final isCreating = createState.isLoading;
    // Gunakan helper findByEventId dari controller untuk menghindari dynamic call.
    final alreadyRsvp =
        ref.watch(myRsvpControllerProvider.notifier).findByEventId(event.id) !=
        null;

    // Event selesai — tampilkan status kehadiran (bukan tombol daftar).
    if (event.status == EventStatus.completed) {
      return _ActionChip(
        icon: Icons.verified,
        label: 'Kehadiran Terverifikasi',
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        onTap: null,
      );
    }

    // Event sedang berlangsung — tampilkan tombol QR (belum diimplementasi).
    if (event.status == EventStatus.ongoing) {
      return _ActionChip(
        icon: Icons.qr_code_2,
        label: 'Lihat QR Saya',
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        onTap: alreadyRsvp ? () {} : null,
      );
    }

    // Sudah RSVP — tombol disabled.
    if (alreadyRsvp) {
      return _ActionChip(
        icon: Icons.check_circle_outline,
        label: 'Sudah Terdaftar',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    // RSVP sedang diproses — tombol loading.
    if (isCreating) {
      return _ActionChip(
        icon: Icons.hourglass_top,
        label: 'Mendaftar...',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        onTap: null,
      );
    }

    // RSVP masih loading (cek cache) — disabled sementara.
    if (myRsvpAsync.isLoading) {
      return _ActionChip(
        icon: Icons.assignment_outlined,
        label: 'Daftar Kegiatan',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        onTap: null,
      );
    }

    // Default: belum RSVP, event PUBLISHED.
    return _ActionChip(
      icon: Icons.assignment_outlined,
      label: 'Daftar Kegiatan',
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      onTap: () => ref
          .read(createRsvpControllerProvider.notifier)
          .createRsvp(event.id),
    );
  }
}

/// Tombol aksi bergaya chip yang digunakan di halaman detail event peserta.
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
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
