import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_rsvp_controller.g.dart';

/// Mengambil dan menyimpan daftar RSVP milik user yang sedang login.
///
/// Dipakai oleh halaman detail event untuk mengecek apakah user
/// sudah RSVP ke event tersebut, tanpa request tambahan per event.
///
/// keepAlive: true agar data tidak di-dispose saat navigasi antar halaman.
@Riverpod(keepAlive: true)
class MyRsvpController extends _$MyRsvpController {
  @override
  Future<List<Rsvp>> build() async {
    // Gunakan read agar tidak memicu only_use_keep_alive_inside_keep_alive.
    final useCase = ref.read(getMyRsvpsUseCaseProvider);
    final result = await useCase(NoInput.instance);
    return result.fold(
      (failure) => throw failure,
      (paginated) => paginated.data,
    );
  }

  /// Cek apakah user sudah RSVP ke event dengan [eventId].
  ///
  /// Mengembalikan [Rsvp] jika sudah RSVP, `null` jika belum.
  Rsvp? findByEventId(String eventId) {
    final list = state.whenOrNull(data: (v) => v);
    if (list == null) return null;
    for (final rsvp in list) {
      if (rsvp.eventId == eventId) return rsvp;
    }
    return null;
  }
}
