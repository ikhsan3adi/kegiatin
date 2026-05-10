import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:kegiatin/presentation/widgets/event_list_card.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class PesertaDashboardPage extends ConsumerWidget {
  const PesertaDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final eventListState = ref.watch(eventListControllerProvider());

    return authState.when(
      data: (user) => SingleChildScrollView(
        child: Column(
          children: [
            KegiatinAppBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/LogoKegiaTin 2.png', width: 32, height: 32),
                          const SizedBox(width: 8),
                          Text(
                            'KEGIATIN',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: colorScheme.onPrimary,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selamat Datang',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.displayName ?? '-',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kegiatan Terkini',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            eventListState.when(
              data: (paginatedResult) {
                // Filter: Hanya tampilkan yang Berlangsung (ongoing) atau Segera (published)
                final filteredEvents = paginatedResult.data.where((event) {
                  return event.status == EventStatus.ongoing ||
                      event.status == EventStatus.published;
                }).toList();

                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Belum ada kegiatan terbaru',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredEvents.length, // Tampilkan semua yang lolos filter
                  itemBuilder: (context, index) {
                    return EventListCard(event: filteredEvents[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
