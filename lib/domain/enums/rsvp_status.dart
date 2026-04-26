import 'package:json_annotation/json_annotation.dart';

enum RsvpStatus {
  @JsonValue('CONFIRMED')
  confirmed,

  @JsonValue('CANCELLED')
  cancelled,

  @JsonValue('WAITLIST')
  waitlist;
}
