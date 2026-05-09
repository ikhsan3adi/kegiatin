import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/complete_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event_list_controller.dart';
import 'package:kegiatin/presentation/controllers/publish_event_controller.dart';
import 'package:kegiatin/presentation/controllers/start_event_controller.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class AdminEventDetailPage extends ConsumerWidget {
  final Event event;

  const AdminEventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to publish state
    ref.listen(publishEventControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (next is AsyncData && next.value != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kegiatan berhasil di-publish!')));
        ref.invalidate(eventListProvider);
        context.pop();
      }
    });

    // Listen to start state
    ref.listen(startEventControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (next is AsyncData && next.value != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kegiatan berhasil dimulai!')));
        ref.invalidate(eventListProvider);
        context.pop();
      }
    });

    // Listen to complete state
    ref.listen(completeEventControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (next is AsyncData && next.value != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kegiatan berhasil diselesaikan!')));
        ref.invalidate(eventListProvider);
        context.pop();
      }
    });

    final publishState = ref.watch(publishEventControllerProvider);
    final startState = ref.watch(startEventControllerProvider);
    final completeState = ref.watch(completeEventControllerProvider);
    final isPublishing = publishState.isLoading;
    final isStarting = startState.isLoading;
    final isCompleting = completeState.isLoading;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Ambil sesi pertama untuk info waktu
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

          // Tab "Info"
          Container(
            width: double.infinity,
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Detail Kegiatan (Admin)',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Deskripsi Card
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

                  // Detail Card
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Actions untuk Admin
          _buildAdminActionBottomBar(context, ref, isPublishing, isStarting, isCompleting),
        ],
      ),
    );
  }

  Widget _buildAdminActionBottomBar(
    BuildContext context,
    WidgetRef ref,
    bool isPublishing,
    bool isStarting,
    bool isCompleting,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDraft = event.status == EventStatus.draft;
    final isPublished = event.status == EventStatus.published;
    final isOngoing = event.status == EventStatus.ongoing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tombol Edit
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Simulasi: Pergi ke edit...')));
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Tombol Publish (Hanya jika Draft)
            if (isDraft) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: isPublishing
                      ? null
                      : () {
                          // Jalankan fungsi publish
                          ref.read(publishEventControllerProvider.notifier).publish(event.id);
                        },
                  icon: isPublishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.publish_rounded, size: 18),
                  label: Text(isPublishing ? 'Loading...' : 'Publish'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Tombol Mulai (Hanya jika Published)
            if (isPublished) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: isStarting
                      ? null
                      : () {
                          ref.read(startEventControllerProvider.notifier).start(event.id);
                        },
                  icon: isStarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(isStarting ? 'Loading...' : 'Mulai'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Tombol Selesai (Hanya jika Ongoing)
            if (isOngoing) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: isCompleting
                      ? null
                      : () {
                          ref.read(completeEventControllerProvider.notifier).complete(event.id);
                        },
                  icon: isCompleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(isCompleting ? 'Loading...' : 'Selesai'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Tombol Hapus (Hanya Icon agar ringkas)
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Simulasi: Kegiatan dihapus...')));
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(0, 0),
              ),
              child: const Icon(Icons.delete_outline, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
        Text(
          value,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
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
}
