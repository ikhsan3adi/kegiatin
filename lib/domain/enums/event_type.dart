import 'package:json_annotation/json_annotation.dart';

enum EventType {
  @JsonValue('SINGLE')
  single,

  @JsonValue('SERIES')
  series;

  static EventType fromJson(String value) {
    final upper = value.toUpperCase();
    return EventType.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown EventType: $value'),
    );
  }

  String toJson() => name.toUpperCase();
}
