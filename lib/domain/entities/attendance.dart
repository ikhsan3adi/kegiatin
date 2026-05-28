import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';

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
  final DateTime checkedInAt;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final UserSummary? user;

  const Attendance({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.rsvpId,
    required this.status,
    required this.syncStatus,
    required this.checkedInAt,
    this.syncedAt,
    required this.createdAt,
    this.user,
  });
}
