import 'package:kegiatin/domain/enums/session_status.dart';

/// Entitas sesi kegiatan.
///
/// Setiap event minimal memiliki 1 sesi.
/// Field [order] menentukan urutan tampil (1, 2, 3, ...).
/// [capacity] null berarti tidak ada batas peserta.
class Session {
  final String id;
  final String eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final int order;
  final SessionStatus status;
  final int? capacity;

  const Session({
    required this.id,
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.order,
    required this.status,
    this.capacity,
  });
}
