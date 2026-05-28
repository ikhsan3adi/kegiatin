import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class InviteUserParams {
  final String eventId;
  final String userId;
  const InviteUserParams({required this.eventId, required this.userId});
}

class InviteUserUseCase extends UseCase<Rsvp, InviteUserParams> {
  final RsvpRepository repository;

  InviteUserUseCase(this.repository);

  @override
  Future<Either<Failure, Rsvp>> call(InviteUserParams params) =>
      repository.inviteUser(params.eventId, params.userId);
}
