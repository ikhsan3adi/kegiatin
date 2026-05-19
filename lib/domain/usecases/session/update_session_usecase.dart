import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/repositories/session_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class UpdateSessionUseCase extends UseCase<Session, UpdateSessionParams> {
  final SessionRepository repository;

  UpdateSessionUseCase(this.repository);

  @override
  Future<Either<Failure, Session>> call(UpdateSessionParams params) async {
    return repository.updateSession(
      params.id,
      title: params.title,
      startTime: params.startTime,
      endTime: params.endTime,
      location: params.location,
      capacity: params.capacity,
    );
  }
}

class UpdateSessionParams {
  final String id;
  final String? title;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final int? capacity;

  const UpdateSessionParams({
    required this.id,
    this.title,
    this.startTime,
    this.endTime,
    this.location,
    this.capacity,
  });
}
