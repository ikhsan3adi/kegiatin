import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/presentation/controllers/rsvp/my_rsvp_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_rsvp_controller.g.dart';

/// Controller untuk aksi mendaftar (RSVP) ke sebuah event.
///
/// State: `null` = idle/belum pernah daftar dalam sesi ini,
/// `Rsvp` = berhasil daftar (berisi qrToken).
@riverpod
class CreateRsvpController extends _$CreateRsvpController {
  @override
  AsyncValue<Rsvp?> build() => const AsyncValue.data(null);

  Future<void> createRsvp(String eventId) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(createRsvpUseCaseProvider);

    final result = await useCase(eventId);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (rsvp) {
        state = AsyncValue.data(rsvp);
        // Invalidasi cache RSVP agar MyRsvpController reload otomatis.
        ref.invalidate(myRsvpControllerProvider);
      },
    );
  }
}
