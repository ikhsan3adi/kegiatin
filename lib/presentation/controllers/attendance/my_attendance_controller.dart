import 'dart:convert';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/data/models/attendance_model.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';

part 'my_attendance_controller.g.dart';

@Riverpod(keepAlive: true)
class MyAttendanceController extends _$MyAttendanceController {
  @override
  FutureOr<List<Attendance>> build() async {
    final authState = ref.watch(authControllerProvider).value;
    if (authState == null) return [];

    final box = ref.read(attendanceBoxProvider);
    final list = <Attendance>[];
    for (final raw in box.values) {
      if (raw is String) {
        final model = AttendanceModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
        if (model.userId == authState.id) {
          list.add(model.toEntity());
        }
      }
    }
    return list;
  }

  Attendance? findBySessionId(String sessionId) {
    final list = state.whenOrNull(data: (v) => v);
    if (list == null) return null;
    for (final attendance in list) {
      if (attendance.sessionId == sessionId) return attendance;
    }
    return null;
  }
}
