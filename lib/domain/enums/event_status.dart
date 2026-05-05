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

  static EventStatus fromJson(String value) {
    final upper = value.toUpperCase();
    return EventStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown EventStatus: $value'),
    );
  }

  String toJson() => name.toUpperCase();
}
