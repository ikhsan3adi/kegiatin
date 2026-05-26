import 'package:kegiatin/domain/enums/archive_type.dart';

class ArchiveItem {
  final String id;
  final String sessionId;
  final String title;
  final ArchiveType type;
  final String fileUrl;
  final DateTime createdAt;

  const ArchiveItem({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.type,
    required this.fileUrl,
    required this.createdAt,
  });
}
