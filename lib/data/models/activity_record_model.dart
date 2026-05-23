import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/data/models/event_model.dart';
import 'package:kegiatin/data/models/session_model.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';

part 'activity_record_model.freezed.dart';
part 'activity_record_model.g.dart';

@freezed
abstract class ActivityRecordModel with _$ActivityRecordModel {
  const factory ActivityRecordModel({
    required EventModel event,
    @Default([]) List<SessionAttendanceModel> attendancePerSession,
  }) = _ActivityRecordModel;

  factory ActivityRecordModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityRecordModelFromJson(json);
}

@freezed
abstract class SessionAttendanceModel with _$SessionAttendanceModel {
  const factory SessionAttendanceModel({
    required SessionModel session,
    required AttendanceStatus? status,
    DateTime? checkedInAt,
  }) = _SessionAttendanceModel;

  factory SessionAttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$SessionAttendanceModelFromJson(json);
}
