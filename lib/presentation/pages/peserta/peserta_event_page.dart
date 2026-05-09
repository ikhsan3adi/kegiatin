import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/presentation/controllers/event_list_controller.dart';
import 'package:kegiatin/presentation/pages/peserta/widget/peserta_card_event.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class AcaraPage extends ConsumerWidget {
  const AcaraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final eventListState = ref.watch(eventListProvider());

    return eventListState.when(
      data: (paginatedEvents) {
        final events = paginatedEvents.data;
        return SingleChildScrollView(
          child: Column(
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
                    Text(
                      '${events.length} Kegiatan Tersedia',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (events.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Belum ada kegiatan',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return CardEvent(
                      event: events[index],
                      showActionButton: true,
                      onTap: () {
                        context.push('/peserta/event-detail', extra: events[index]);
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Gagal memuat kegiatan: $err')),
    );
  }
}
