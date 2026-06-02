import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/usecases/session/add_session_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_session_controller.g.dart';

@riverpod
class AddSessionController extends _$AddSessionController {
  @override
  AsyncValue<Session?> build() => const AsyncValue.data(null);

  Future<void> addSession(String eventId, SessionInput input) async {
    final keepAliveLink = ref.keepAlive();
    try {
      state = const AsyncValue.loading();
      final useCase = ref.read(addSessionUseCaseProvider);
      final result = await useCase(AddSessionParams(eventId: eventId, input: input));
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (session) => state = AsyncValue.data(session),
      );
    } finally {
      keepAliveLink.close();
    }
  }
}
