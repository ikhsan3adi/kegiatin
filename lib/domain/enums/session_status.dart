import 'package:json_annotation/json_annotation.dart';

enum SessionStatus {
  @JsonValue('SCHEDULED')
  scheduled,

  @JsonValue('ONGOING')
  ongoing,

  @JsonValue('COMPLETED')
  completed,

  @JsonValue('POSTPONED')
  postponed;
}
