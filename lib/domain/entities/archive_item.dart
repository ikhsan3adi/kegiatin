import 'package:kegiatin/domain/enums/archive_type.dart';

/// Entitas arsip digital per sesi kegiatan.
///
/// Bisa berupa materi kajian (PDF/link), dokumentasi foto,
/// atau notulensi/evaluasi.
class ArchiveItem {
  final String id;
  final String sessionId;
  final String uploadedBy;
  final ArchiveType type;
  final String fileUrl;
  final String title;
  final DateTime uploadedAt;

  const ArchiveItem({
    required this.id,
    required this.sessionId,
    required this.uploadedBy,
    required this.type,
    required this.fileUrl,
    required this.title,
    required this.uploadedAt,
  });
}
