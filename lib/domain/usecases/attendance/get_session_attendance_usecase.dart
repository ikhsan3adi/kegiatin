import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/repositories/attendance_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetSessionAttendanceUseCase extends UseCase<List<Attendance>, String> {
  final AttendanceRepository repository;

  GetSessionAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, List<Attendance>>> call(String sessionId) =>
      repository.getAttendanceBySession(sessionId);
}
