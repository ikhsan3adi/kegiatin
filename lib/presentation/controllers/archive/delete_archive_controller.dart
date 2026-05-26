import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_archive_controller.g.dart';

@riverpod
class DeleteArchiveController extends _$DeleteArchiveController {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    final ref = this.ref;
    final useCase = ref.read(deleteArchiveUseCaseProvider);
    final result = await useCase(id);
    state = result.fold(
      (failure) => AsyncError(Exception(failure.message), StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
