import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/usecases/event/update_event_usecase.dart';
import 'package:kegiatin/presentation/providers/event_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_event_controller.g.dart';

@riverpod
class UpdateEventController extends _$UpdateEventController {
  @override
  FutureOr<void> build() {}

  Future<String?> submit(String eventId, UpdateEventInput input) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(updateEventUseCaseProvider);
    final result = await useCase(UpdateEventUseCaseParams(eventId: eventId, input: input));

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        // Refresh detail and list
        ref.invalidate(getEventByIdUseCaseProvider);
        ref.invalidate(getEventsUseCaseProvider);
        return null;
      },
    );
  }
}
