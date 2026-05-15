import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/pages/peserta/widget/peserta_event_detail_body.dart';
import 'package:kegiatin/presentation/pages/peserta/widget/peserta_event_detail_header.dart';
import 'package:kegiatin/presentation/pages/peserta/widget/peserta_event_detail_listeners.dart';

class PesertaEventDetailPage extends ConsumerWidget {
  const PesertaEventDetailPage({super.key, required this.eventId});

  /// UUID dari route `/peserta/event-detail/:eventId`.
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvent = ref.watch(eventDetailControllerProvider(eventId));

    return asyncEvent.when(
      loading: () => _fallbackScaffold(
        context,
        const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _fallbackScaffold(
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
      data: (event) => _PesertaEventDetailLoaded(event: event),
    );
  }

  Widget _fallbackScaffold(BuildContext context, Widget body) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      body: body,
    );
  }
}

class _PesertaEventDetailLoaded extends ConsumerWidget {
  const _PesertaEventDetailLoaded({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return PesertaEventDetailListeners(
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        body: Column(
          children: [
            PesertaEventDetailHeader(event: event),
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
            Expanded(child: PesertaEventDetailBody(event: event)),
          ],
        ),
      ),
    );
  }
}
