import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

/// Mengambil semua RSVP milik user yang sedang login.
///
/// Dipakai untuk mengecek apakah user sudah RSVP ke suatu event
/// dengan mem-filter berdasarkan [Rsvp.eventId] di sisi client.
class GetMyRsvpsUseCase extends UseCase<PaginatedResult<Rsvp>, NoInput> {
  final RsvpRepository repository;

  GetMyRsvpsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResult<Rsvp>>> call(NoInput input) =>
      repository.getMyRsvps();
}
