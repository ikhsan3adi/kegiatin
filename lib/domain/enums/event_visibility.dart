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

  /// Returns the wire format string (SCREAMING_SNAKE_CASE) for API requests.
  /// e.g. [EventVisibility.inviteOnly] → `'INVITE_ONLY'`
  String toJson() =>
      name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)!}').toUpperCase();
}
