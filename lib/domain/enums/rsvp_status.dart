import 'package:json_annotation/json_annotation.dart';

enum RsvpStatus {
  @JsonValue('CONFIRMED')
  confirmed,

  @JsonValue('CANCELLED')
  cancelled,

  @JsonValue('WAITLIST')
  waitlist;

  static RsvpStatus fromJson(String value) {
    final upper = value.toUpperCase();
    return RsvpStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown RsvpStatus: $value'),
    );
  }
}
