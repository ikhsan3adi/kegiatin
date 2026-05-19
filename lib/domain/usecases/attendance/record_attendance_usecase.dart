import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/repositories/attendance_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class RecordAttendanceUseCase extends UseCase<Attendance, RecordAttendanceParams> {
  final AttendanceRepository repository;

  RecordAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, Attendance>> call(RecordAttendanceParams input) =>
      repository.scanQr(input.qrToken, input.sessionId);
}

class RecordAttendanceParams {
  final String qrToken;
  final String sessionId;

  const RecordAttendanceParams({required this.qrToken, required this.sessionId});
}
