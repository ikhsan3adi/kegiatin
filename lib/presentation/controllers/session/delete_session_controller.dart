import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_session_controller.g.dart';

@riverpod
class DeleteSessionController extends _$DeleteSessionController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> deleteSession(String sessionId) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(deleteSessionUseCaseProvider);
    final result = await useCase(sessionId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
