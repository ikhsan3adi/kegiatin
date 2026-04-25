import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/domain/entities/session.dart';

/// Entitas kegiatan.
///
/// Single Event memiliki tepat 1 sesi eksplisit.
/// Series Event memiliki banyak sesi yang di-generate client-side
/// berdasarkan pola pengulangan (mingguan/bulanan/custom).
class Event {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final EventStatus status;
  final EventVisibility visibility;
  final String location;
  final String contactPerson;
  final String? imageUrl;
  final String createdBy;
  final List<Session> sessions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.visibility,
    required this.location,
    required this.contactPerson,
    this.imageUrl,
    required this.createdBy,
    this.sessions = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}
