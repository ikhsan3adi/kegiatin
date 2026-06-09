import 'package:kegiatin/domain/enums/notification_type.dart';

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? eventId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.eventId,
    required this.isRead,
    required this.createdAt,
  });
}
