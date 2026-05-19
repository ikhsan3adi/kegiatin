import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/attendance_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class SyncAttendanceUseCase extends UseCase<void, NoInput> {
  final AttendanceRepository repository;

  SyncAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoInput input) => repository.syncPendingAttendance();
}
