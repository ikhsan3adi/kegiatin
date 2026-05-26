import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/controllers/attendance/my_attendance_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_controller.g.dart';

@riverpod
class SyncController extends _$SyncController {
  @override
  FutureOr<void> build() => null;

  Future<void> syncNow() async {
    state = const AsyncLoading();
    final useCase = ref.read(syncAttendanceUseCaseProvider);
    final result = await useCase(NoInput.instance);
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), (_) {
      ref.invalidate(myAttendanceControllerProvider);
      return const AsyncData(null);
    });
  }
}
