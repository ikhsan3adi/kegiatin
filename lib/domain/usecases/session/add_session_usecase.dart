import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/repositories/session_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class AddSessionUseCase extends UseCase<Session, AddSessionParams> {
  final SessionRepository repository;

  AddSessionUseCase(this.repository);

  @override
  Future<Either<Failure, Session>> call(AddSessionParams params) async {
    return repository.addSession(params.eventId, params.input);
  }
}

class AddSessionParams {
  final String eventId;
  final SessionInput input;

  const AddSessionParams({required this.eventId, required this.input});
}
