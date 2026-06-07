import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/core/utils/json_utils.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';

part 'archive_model.freezed.dart';
part 'archive_model.g.dart';

@freezed
abstract class ArchiveModel with _$ArchiveModel implements ArchiveItem {
  const ArchiveModel._();

  const factory ArchiveModel({
    required String id,
    required String sessionId,
    required String title,
    required ArchiveType type,
    required String fileUrl,
    @JsonKey(fromJson: JsonUtils.dateTimeFromJson, toJson: JsonUtils.dateTimeToJson)
    required DateTime createdAt,
    String? localFilePath,
  }) = _ArchiveModel;

  factory ArchiveModel.fromJson(Map<String, dynamic> json) => _$ArchiveModelFromJson(json);
}
