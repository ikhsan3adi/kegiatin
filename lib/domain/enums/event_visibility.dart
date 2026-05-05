import 'package:json_annotation/json_annotation.dart';

enum EventVisibility {
  @JsonValue('OPEN')
  open,

  @JsonValue('INVITE_ONLY')
  inviteOnly;

  static EventVisibility fromJson(String value) {
    final upper = value.toUpperCase();
    return EventVisibility.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown EventVisibility: $value'),
    );
  }
}
