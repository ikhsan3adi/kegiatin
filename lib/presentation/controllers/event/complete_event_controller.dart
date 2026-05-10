import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'complete_event_controller.g.dart';

@riverpod
class CompleteEventController extends _$CompleteEventController {
  @override
  AsyncValue<Event?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> complete(String eventId) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(completeEventUseCaseProvider);

    final result = await useCase(eventId);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (event) {
        state = AsyncValue.data(event);
      },
    );
  }
}
