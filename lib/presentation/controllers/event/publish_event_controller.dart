import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'publish_event_controller.g.dart';

@riverpod
class PublishEventController extends _$PublishEventController {
  @override
  AsyncValue<Event?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> publish(String eventId) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(publishEventUseCaseProvider);

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
