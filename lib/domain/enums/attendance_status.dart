import 'package:json_annotation/json_annotation.dart';

enum AttendanceStatus {
  @JsonValue('PRESENT')
  present,

  @JsonValue('LATE')
  late,

  @JsonValue('ABSENT')
  absent;
}
