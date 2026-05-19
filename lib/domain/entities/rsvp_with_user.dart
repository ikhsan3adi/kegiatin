import 'package:kegiatin/domain/enums/rsvp_status.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';

class RsvpWithUser {
  final String id;
  final String userId;
  final String eventId;
  final String qrToken;
  final RsvpStatus status;
  final DateTime createdAt;
  final UserSummary user;

  const RsvpWithUser({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.qrToken,
    required this.status,
    required this.createdAt,
    required this.user,
  });
}
