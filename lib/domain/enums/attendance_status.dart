import 'package:json_annotation/json_annotation.dart';

enum AttendanceStatus {
  @JsonValue('PRESENT')
  present,

  @JsonValue('LATE')
  late,

  @JsonValue('ABSENT')
  absent;

  static AttendanceStatus fromJson(String value) {
    final upper = value.toUpperCase();
    return AttendanceStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown AttendanceStatus: $value'),
    );
  }
}
