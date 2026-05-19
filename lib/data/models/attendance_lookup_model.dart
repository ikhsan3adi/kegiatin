import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/data/models/attendance_user_brief_model.dart';

part 'attendance_lookup_model.freezed.dart';
part 'attendance_lookup_model.g.dart';

@freezed
abstract class AttendanceLookupResponse with _$AttendanceLookupResponse {
  const AttendanceLookupResponse._();

  const factory AttendanceLookupResponse({
    required bool validForSession,
    required String rsvpId,
    required String userId,
    required String eventId,
    required String sessionId,
    required AttendanceUserBriefModel user,
    String? reason,
  }) = _AttendanceLookupResponse;

  factory AttendanceLookupResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLookupResponseFromJson(json);
}
