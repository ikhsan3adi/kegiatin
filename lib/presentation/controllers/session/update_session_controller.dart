import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/usecases/session/update_session_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_session_controller.g.dart';

@riverpod
class UpdateSessionController extends _$UpdateSessionController {
  @override
  AsyncValue<Session?> build() => const AsyncValue.data(null);

  Future<void> updateSession(String id, UpdateSessionParams params) async {
    final keepAliveLink = ref.keepAlive();
    try {
      state = const AsyncValue.loading();
      final useCase = ref.read(updateSessionUseCaseProvider);
      final result = await useCase(params);
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (session) => state = AsyncValue.data(session),
      );
    } finally {
      keepAliveLink.close();
    }
  }
}
