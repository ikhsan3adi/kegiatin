import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

/// Membuat RSVP untuk event yang diberikan (input = eventId).
///
/// Server membatasi 1 RSVP per user per event.
/// Untuk Series Event, 1 RSVP mencakup seluruh sesi.
class CreateRsvpUseCase extends UseCase<Rsvp, String> {
  final RsvpRepository repository;

  CreateRsvpUseCase(this.repository);

  @override
  Future<Either<Failure, Rsvp>> call(String eventId) =>
      repository.createRsvp(eventId);
}
