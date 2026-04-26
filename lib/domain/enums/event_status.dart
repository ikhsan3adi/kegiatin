import 'package:json_annotation/json_annotation.dart';

enum EventStatus {
  @JsonValue('DRAFT')
  draft,

  @JsonValue('PUBLISHED')
  published,

  @JsonValue('ONGOING')
  ongoing,

  @JsonValue('COMPLETED')
  completed,

  @JsonValue('CANCELLED')
  cancelled;
}
