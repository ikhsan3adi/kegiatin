import 'package:json_annotation/json_annotation.dart';

enum EventType {
  @JsonValue('SINGLE')
  single,

  @JsonValue('SERIES')
  series;
}
