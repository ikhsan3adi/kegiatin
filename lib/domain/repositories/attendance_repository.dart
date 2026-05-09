import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, Attendance>> scanQr(String qrToken, String sessionId);
  Future<Either<Failure, void>> syncPendingAttendance();
  Future<Either<Failure, List<Attendance>>> getAttendanceBySession(String sessionId);
}
