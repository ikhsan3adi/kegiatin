import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';

part 'sync_result_model.freezed.dart';
part 'sync_result_model.g.dart';

@freezed
abstract class SyncResultResponse with _$SyncResultResponse {
  const SyncResultResponse._();

  const factory SyncResultResponse({
    required List<SyncResultItem> results,
    required SyncResultSummary summary,
  }) = _SyncResultResponse;

  factory SyncResultResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResultResponseFromJson(json);
}

@freezed
abstract class SyncResultItem with _$SyncResultItem {
  const SyncResultItem._();

  const factory SyncResultItem({
    required String localId,
    required String status,
    String? serverId,
    String? reason,
  }) = _SyncResultItem;

  factory SyncResultItem.fromJson(Map<String, dynamic> json) => _$SyncResultItemFromJson(json);
}

@freezed
abstract class SyncResultSummary with _$SyncResultSummary {
  const SyncResultSummary._();

  const factory SyncResultSummary({
    required int synced,
    required int conflict,
    required int invalid,
  }) = _SyncResultSummary;

  factory SyncResultSummary.fromJson(Map<String, dynamic> json) =>
      _$SyncResultSummaryFromJson(json);
}

class SyncAttendanceRecord {
  final String localId;
  final String qrToken;
  final String sessionId;
  final DateTime checkedInAt;
  final AttendanceStatus? status;

  const SyncAttendanceRecord({
    required this.localId,
    required this.qrToken,
    required this.sessionId,
    required this.checkedInAt,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'qrToken': qrToken,
    'sessionId': sessionId,
    'checkedInAt': checkedInAt.toIso8601String(),
    if (status != null) 'status': status!.name.toUpperCase(),
  };
}

class SyncAttendanceBatchRequest {
  final List<SyncAttendanceRecord> records;

  const SyncAttendanceBatchRequest({required this.records});

  Map<String, dynamic> toJson() => {'records': records.map((r) => r.toJson()).toList()};
}
