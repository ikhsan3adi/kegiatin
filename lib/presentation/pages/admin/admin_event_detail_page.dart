import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/controllers/event/complete_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/controllers/event/publish_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event/start_event_controller.dart';
import 'package:kegiatin/presentation/pages/admin/widget/admin_event_detail_body.dart';
import 'package:kegiatin/presentation/pages/admin/widget/admin_event_detail_bottom_bar.dart';
import 'package:kegiatin/presentation/pages/admin/widget/admin_event_detail_header.dart';
import 'package:kegiatin/presentation/pages/admin/widget/admin_event_detail_listeners.dart';

class AdminEventDetailPage extends ConsumerWidget {
  const AdminEventDetailPage({super.key, required this.eventId});

  /// UUID dari route `/admin/event-detail/:eventId`.
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvent = ref.watch(eventDetailControllerProvider(eventId));

    return asyncEvent.when(
      loading: () => _loadingOrErrorScaffold(
        context,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _loadingOrErrorScaffold(
        context,
        body: Center(
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
      data: (event) => _AdminEventDetailLoaded(event: event),
    );
  }

  Widget _loadingOrErrorScaffold(BuildContext context, {required Widget body}) {
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
}

class _AdminEventDetailLoaded extends ConsumerWidget {
  const _AdminEventDetailLoaded({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishState = ref.watch(publishEventControllerProvider);
    final startState = ref.watch(startEventControllerProvider);
    final completeState = ref.watch(completeEventControllerProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return AdminEventDetailListeners(
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        body: Column(
          children: [
            AdminEventDetailHeader(event: event),
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
            Expanded(child: AdminEventDetailBody(event: event)),
            AdminEventDetailBottomBar(
              event: event,
              isPublishing: publishState.isLoading,
              isStarting: startState.isLoading,
              isCompleting: completeState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
