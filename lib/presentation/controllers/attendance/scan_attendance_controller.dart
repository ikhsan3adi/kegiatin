import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/usecases/attendance/record_attendance_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scan_attendance_controller.g.dart';

@riverpod
class ScanAttendanceController extends _$ScanAttendanceController {
  @override
  FutureOr<Attendance?> build() => null;

  Future<void> scan(String qrToken, String sessionId) async {
    state = const AsyncLoading();
    final useCase = ref.read(recordAttendanceUseCaseProvider);
    final result = await useCase(RecordAttendanceParams(qrToken: qrToken, sessionId: sessionId));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (attendance) => AsyncData(attendance),
    );
  }
}
