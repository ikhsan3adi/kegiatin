import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_detail_controller.g.dart';

@riverpod
class EventDetail extends _$EventDetail {
  @override
  FutureOr<Event> build(String id) async {
    return _fetchEventById(id);
  }

  Future<Event> _fetchEventById(String id) async {
    final useCase = ref.watch(getEventByIdUseCaseProvider);
    final result = await useCase(id);

    return result.fold((failure) => throw Exception(failure.message), (data) => data);
  }
}
