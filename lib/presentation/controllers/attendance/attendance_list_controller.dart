import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_list_controller.g.dart';

@riverpod
class AttendanceListController extends _$AttendanceListController {
  @override
  Future<List<Attendance>> build(String sessionId) async {
    final useCase = ref.read(getSessionAttendanceUseCaseProvider);
    final result = await useCase(sessionId);
    return result.fold((failure) => throw failure, (list) => list);
  }
}
