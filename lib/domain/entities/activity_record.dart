import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/session.dart';

/// Ringkasan keikutsertaan peserta di sebuah event.
///
/// Bukan tabel/koleksi tersendiri di database — backend membentuk data ini
/// melalui aggregation dari koleksi Attendance + Session + Event.
class ActivityRecord {
  final Event event;
  final List<SessionAttendance> attendancePerSession;

  const ActivityRecord({
    required this.event,
    this.attendancePerSession = const [],
  });
}

/// Status kehadiran peserta pada satu sesi dalam konteks activity history.
class SessionAttendance {
  final Session session;
  final AttendanceStatus status;
  final DateTime? checkedInAt;

  const SessionAttendance({
    required this.session,
    required this.status,
    this.checkedInAt,
  });
}
