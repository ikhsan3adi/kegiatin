import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/usecases/get_event_rsvps_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_rsvp_list_controller.g.dart';

@riverpod
class EventRsvpListController extends _$EventRsvpListController {
  @override
  FutureOr<PaginatedResult<RsvpWithUser>> build(String eventId) async {
    return _fetchRsvps(eventId);
  }

  Future<PaginatedResult<RsvpWithUser>> _fetchRsvps(String eventId) async {
    final useCase = ref.read(getEventRsvpsUseCaseProvider);
    final result = await useCase(GetEventRsvpsParams(eventId: eventId));
    return result.fold((failure) => throw Exception(failure.message), (data) => data);
  }
}
