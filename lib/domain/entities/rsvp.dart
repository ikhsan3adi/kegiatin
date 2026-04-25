import 'package:kegiatin/domain/enums/rsvp_status.dart';

/// Entitas reservasi peserta terhadap sebuah event.
///
/// Satu user hanya boleh punya 1 RSVP per event.
/// Untuk Series Event, 1 RSVP mencakup seluruh sesi.
/// [qrToken] digunakan untuk check-in via QR scan.
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
