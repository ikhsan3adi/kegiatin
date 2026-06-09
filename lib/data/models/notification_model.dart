import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/entities/notification_item.dart';
import 'package:kegiatin/domain/enums/notification_type.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class NotificationModel with _$NotificationModel implements NotificationItem {
  const factory NotificationModel({
    required String id,
    @JsonKey(name: 'type', fromJson: _typeFromJson, toJson: _typeToJson)
    required NotificationType type,
    required String title,
    required String body,
    String? eventId,
    required bool isRead,
    required DateTime createdAt,
  }) = _NotificationModel;

  const NotificationModel._();

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  factory NotificationModel.fromEntity(NotificationItem entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      eventId: entity.eventId,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  NotificationItem toEntity() {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      eventId: eventId,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}

NotificationType _typeFromJson(String value) => NotificationType.fromValue(value);
String _typeToJson(NotificationType type) => type.value;
