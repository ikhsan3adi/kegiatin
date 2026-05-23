import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';

part 'archive_model.freezed.dart';
part 'archive_model.g.dart';

@freezed
abstract class ArchiveModel with _$ArchiveModel {
  const ArchiveModel._();

  const factory ArchiveModel({
    required String id,
    required String sessionId,
    required String title,
    required ArchiveType type,
    required String fileUrl,
    required DateTime createdAt,
  }) = _ArchiveModel;

  factory ArchiveModel.fromJson(Map<String, dynamic> json) => _$ArchiveModelFromJson(json);
}
