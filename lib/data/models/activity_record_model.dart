import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/core/utils/json_utils.dart';
import 'package:kegiatin/data/models/event_model.dart';
import 'package:kegiatin/data/models/session_model.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';

part 'activity_record_model.freezed.dart';
part 'activity_record_model.g.dart';

@freezed
abstract class ActivityRecordModel with _$ActivityRecordModel implements ActivityRecord {
  const factory ActivityRecordModel({
    required EventModel event,
    @Default([]) List<SessionAttendanceModel> attendancePerSession,
  }) = _ActivityRecordModel;

  factory ActivityRecordModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityRecordModelFromJson(json);
}

@freezed
abstract class SessionAttendanceModel with _$SessionAttendanceModel implements SessionAttendance {
  const factory SessionAttendanceModel({
    required SessionModel session,
    required AttendanceStatus? status,
    @JsonKey(fromJson: JsonUtils.nullableDateTimeFromJson, toJson: JsonUtils.nullableDateTimeToJson)
    DateTime? checkedInAt,
  }) = _SessionAttendanceModel;

  factory SessionAttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$SessionAttendanceModelFromJson(json);
}
