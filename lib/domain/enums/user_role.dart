import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('ADMIN')
  admin,

  @JsonValue('MEMBER')
  member;

  String toJsonString() => name.toUpperCase();
}
