import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_event_controller.g.dart';

/// State: null = idle, Event = berhasil dibuat.
@riverpod
class CreateEventController extends _$CreateEventController {
  @override
  AsyncValue<Event?> build() => const AsyncData(null);

  /// Mengirim data kegiatan baru ke backend.
  ///
  /// Mengembalikan pesan error jika gagal, null jika berhasil.
  Future<String?> submit(CreateEventInput input) async {
    state = const AsyncLoading();
    final result = await ref.read(createEventUseCaseProvider).call(input);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure.message;
      },
      (event) {
        state = AsyncData(event);
        return null;
      },
    );
  }

  void reset() => state = const AsyncData(null);
}
