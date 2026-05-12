import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/controllers/event/cancel_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event/complete_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:kegiatin/presentation/controllers/event/publish_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event/start_event_controller.dart';

/// Side-effect listeners for publish / start / complete (snackbar, invalidate list, pop).
class AdminEventDetailListeners extends ConsumerWidget {
  const AdminEventDetailListeners({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onSuccess(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      ref.invalidate(eventListControllerProvider);
      context.pop();
    }

    void onError(Object error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    ref.listen(publishEventControllerProvider, (previous, next) {
      _handleAsyncEvent(next, onSuccess: () => onSuccess('Kegiatan berhasil di-publish!'), onError: onError);
    });
    ref.listen(startEventControllerProvider, (previous, next) {
      _handleAsyncEvent(next, onSuccess: () => onSuccess('Kegiatan berhasil dimulai!'), onError: onError);
    });
    ref.listen(completeEventControllerProvider, (previous, next) {
      _handleAsyncEvent(next, onSuccess: () => onSuccess('Kegiatan berhasil diselesaikan!'), onError: onError);
    });
    ref.listen(cancelEventControllerProvider, (previous, next) {
      _handleAsyncEvent(next, onSuccess: () => onSuccess('Kegiatan berhasil dibatalkan!'), onError: onError);
    });

    return child;
  }
}

void _handleAsyncEvent(
  AsyncValue<Event?> next, {
  required VoidCallback onSuccess,
  required void Function(Object error) onError,
}) {
  if (next is AsyncError) {
    onError(next.error ?? 'Unknown error');
    return;
  }
  if (next is AsyncData<Event?> && next.value != null) {
    onSuccess();
  }
}
