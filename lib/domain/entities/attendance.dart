import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';

/// Entitas kehadiran peserta pada satu sesi.
///
/// Bersifat **immutable** setelah [syncStatus] = [SyncStatus.synced].
/// Admin tidak dapat mengubah record yang sudah tersinkronisasi.
class Attendance {
  final String id;
  final String userId;
  final String sessionId;
  final String rsvpId;
  final AttendanceStatus status;
  final SyncStatus syncStatus;
  final DateTime? checkedInAt;
  final DateTime? syncedAt;

  const Attendance({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.rsvpId,
    required this.status,
    required this.syncStatus,
    this.checkedInAt,
    this.syncedAt,
  });
}
