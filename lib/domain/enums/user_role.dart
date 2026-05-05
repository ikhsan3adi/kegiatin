import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('ADMIN')
  admin,

  @JsonValue('MEMBER')
  member;

  String toJsonString() => name.toUpperCase();

  static UserRole fromJson(String value) {
    final upper = value.toUpperCase();
    return UserRole.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown UserRole: $value'),
    );
  }
}
