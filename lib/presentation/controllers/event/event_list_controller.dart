import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/usecases/get_events_usecase.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_list_controller.g.dart';

@riverpod
class EventListController extends _$EventListController {
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
    
    final currentStatus = status;
    EventStatus? eventStatus;
    if (currentStatus != null) {
      eventStatus = EventStatus.values.firstWhere((e) => e.name.toUpperCase() == currentStatus.toUpperCase(), orElse: () => EventStatus.published);
    }
    
    final currentType = type;
    EventType? eventType;
    if (currentType != null) {
      eventType = EventType.values.firstWhere((e) => e.name.toUpperCase() == currentType.toUpperCase(), orElse: () => EventType.single);
    }

    final result = await useCase(GetEventsUseCaseParams(
      page: page, 
      limit: limit, 
      search: search,
      status: eventStatus,
      type: eventType,
    ));

    return result.fold((failure) => throw Exception(failure.message), (data) => data);
  }
}
