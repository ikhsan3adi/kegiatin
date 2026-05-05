import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/usecases/get_events_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_list_controller.g.dart';

@riverpod
class EventList extends _$EventList {
  @override
  FutureOr<PaginatedResult<Event>> build({
    int page = 1,
    int limit = 10,
    String? status,
    String? type,
    String? search,
  }) async {
    return _fetchEvents();
  }

  Future<PaginatedResult<Event>> _fetchEvents() async {
    final useCase = ref.watch(getEventsUseCaseProvider);
    final result = await useCase(GetEventsUseCaseParams(
      page: page,
      limit: limit,
      search: search,
      // mapping status dan type dari String ke Enum dapat dilakukan di sini jika diperlukan
    ));

    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data,
    );
  }
}
