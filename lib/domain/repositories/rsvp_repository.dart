import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';

/// Interface repository untuk operasi RSVP dari sisi peserta.
abstract class RsvpRepository {
  /// Membuat RSVP baru untuk event dengan [eventId].
  ///
  /// Server menolak dengan 409 jika user sudah RSVP ke event yang sama.
  Future<Either<Failure, Rsvp>> createRsvp(String eventId);

  /// Mengambil daftar RSVP milik user yang sedang login.
  Future<Either<Failure, PaginatedResult<Rsvp>>> getMyRsvps({
    int page = 1,
    int limit = 20,
  });
}
