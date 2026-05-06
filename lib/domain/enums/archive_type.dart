import 'package:json_annotation/json_annotation.dart';

enum ArchiveType {
  @JsonValue('MATERIAL')
  material,

  @JsonValue('PHOTO')
  photo,

  @JsonValue('EVALUATION')
  evaluation;

  static ArchiveType fromJson(String value) {
    final upper = value.toUpperCase();
    return ArchiveType.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown ArchiveType: $value'),
    );
  }

  String toJson() => name.toUpperCase();
}
