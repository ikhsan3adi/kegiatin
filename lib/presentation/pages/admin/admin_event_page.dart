import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:kegiatin/presentation/widgets/event_list_card.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class AdminEventPage extends ConsumerWidget {
  const AdminEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Fetch events (for UI purposes we use the existing provider)
    final eventsState = ref.watch(eventListControllerProvider());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KegiatinAppBar(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kegiatan',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                eventsState.maybeWhen(
                  data: (paginatedData) => Text(
                    '${paginatedData.data.length} Kegiatan Tersedia',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  orElse: () => Text(
                    'Memuat kegiatan...',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),

          eventsState.when(
            data: (paginatedData) {
              final events = paginatedData.data;

              if (events.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Belum ada kegiatan',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventListCard(
                    event: event,
                    showActionButton: false,
                    onTap: () => context.push('/admin/event-detail/${event.id}'),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Gagal memuat kegiatan: $e'),
              ),
            ),
          ),
          const SizedBox(height: 80), // Padding bawah agar tidak tertutup navbar
        ],
      ),
    );
  }
}
