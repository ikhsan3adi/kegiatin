import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cancel_event_controller.g.dart';

@riverpod
class CancelEventController extends _$CancelEventController {
  @override
  AsyncValue<Event?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> cancel(String eventId) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(cancelEventUseCaseProvider);

    final result = await useCase(eventId);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (event) {
        state = AsyncValue.data(event);
        ref.invalidate(eventListControllerProvider);
      },
    );
  }
}
