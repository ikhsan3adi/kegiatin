import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

/// Data model untuk [Attendance] — memetakan response attendance dari API.
@freezed
abstract class AttendanceModel with _$AttendanceModel implements Attendance {
  const AttendanceModel._();

  const factory AttendanceModel({
    required String id,
    required String userId,
    required String sessionId,
    required String rsvpId,
    required AttendanceStatus status,
    required SyncStatus syncStatus,
    String? qrToken,
    required DateTime checkedInAt,
    DateTime? syncedAt,
    required DateTime createdAt,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);
}

extension AttendanceModelX on AttendanceModel {
  Attendance toEntity() => Attendance(
    id: id,
    userId: userId,
    sessionId: sessionId,
    rsvpId: rsvpId,
    status: status,
    syncStatus: syncStatus,
    checkedInAt: checkedInAt,
    syncedAt: syncedAt,
    createdAt: createdAt,
  );
}
