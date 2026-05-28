import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_rsvp_controller.g.dart';

@Riverpod(keepAlive: true)
class MyRsvpController extends _$MyRsvpController {
  @override
  Future<List<Rsvp>> build() async {
    // Gunakan read agar tidak memicu only_use_keep_alive_inside_keep_alive.
    final useCase = ref.read(getMyRsvpsUseCaseProvider);
    final result = await useCase(NoInput.instance);
    return result.fold((failure) => throw failure, (paginated) => paginated.data);
  }

  Rsvp? findByEventId(String eventId) {
    final list = state.whenOrNull(data: (v) => v);
    if (list == null) return null;
    for (final rsvp in list) {
      if (rsvp.eventId == eventId) return rsvp;
    }
    return null;
  }
}
