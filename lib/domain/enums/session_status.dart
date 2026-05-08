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

  static SessionStatus fromJson(String value) {
    final upper = value.toUpperCase();
    return SessionStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown SessionStatus: $value'),
    );
  }

  String toJson() => name.toUpperCase();
}
