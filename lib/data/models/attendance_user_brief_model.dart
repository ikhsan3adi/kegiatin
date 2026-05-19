import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_user_brief_model.freezed.dart';
part 'attendance_user_brief_model.g.dart';

@freezed
abstract class AttendanceUserBriefModel with _$AttendanceUserBriefModel {
  const AttendanceUserBriefModel._();

  const factory AttendanceUserBriefModel({
    required String displayName,
    String? npa,
    String? cabang,
    String? photoUrl,
  }) = _AttendanceUserBriefModel;

  factory AttendanceUserBriefModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceUserBriefModelFromJson(json);
}
