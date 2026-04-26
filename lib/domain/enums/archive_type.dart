import 'package:json_annotation/json_annotation.dart';

enum ArchiveType {
  @JsonValue('MATERIAL')
  material,

  @JsonValue('PHOTO')
  photo,

  @JsonValue('EVALUATION')
  evaluation;
}
