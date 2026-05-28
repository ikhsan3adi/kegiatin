import 'package:kegiatin/domain/enums/rsvp_status.dart';

class Rsvp {
  final String id;
  final String userId;
  final String eventId;
  final String qrToken;
  final RsvpStatus status;
  final DateTime createdAt;

  const Rsvp({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.qrToken,
    required this.status,
    required this.createdAt,
  });
}
