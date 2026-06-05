import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/usecases/get_events_usecase.dart';
import 'package:kegiatin/presentation/providers/event_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_stats_controller.g.dart';

class EventStats {
  final int eventsThisWeek;
  final int eventsThisMonth;
  final int incompleteEvents;
  final int totalAttendances;

  const EventStats({
    required this.eventsThisWeek,
    required this.eventsThisMonth,
    required this.incompleteEvents,
    required this.totalAttendances,
  });
}

@riverpod
class EventStatsController extends _$EventStatsController {
  @override
  FutureOr<EventStats> build() async {
    return _fetchStats(forceRefresh: false);
  }

  Future<EventStats> _fetchStats({bool forceRefresh = false}) async {
    final getEventsUseCase = ref.watch(getEventsUseCaseProvider);

    final eventsResult = await getEventsUseCase.call(
      GetEventsUseCaseParams(page: 1, limit: 1000, forceRefresh: forceRefresh),
    );

    return eventsResult.fold(
      (failure) => const EventStats(
        eventsThisWeek: 0,
        eventsThisMonth: 0,
        incompleteEvents: 0,
        totalAttendances: 0,
      ),
      (paginatedResult) {
        final events = paginatedResult.data;
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        int eventsThisWeek = 0;
        for (final event in events) {
          for (final session in event.sessions) {
            if (session.startTime.isAfter(startOfWeek) &&
                session.startTime.isBefore(endOfWeek.add(const Duration(days: 1)))) {
              eventsThisWeek++;
              break;
            }
          }
        }

        int eventsThisMonth = 0;
        for (final event in events) {
          for (final session in event.sessions) {
            if (session.startTime.isAfter(startOfMonth) &&
                session.startTime.isBefore(endOfMonth.add(const Duration(days: 1)))) {
              eventsThisMonth++;
              break; // Count each event once
            }
          }
        }

        final incompleteEvents = events.where((e) => e.status == EventStatus.draft).length;

        const totalAttendances = 0;

        return EventStats(
          eventsThisWeek: eventsThisWeek,
          eventsThisMonth: eventsThisMonth,
          incompleteEvents: incompleteEvents,
          totalAttendances: totalAttendances,
        );
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats(forceRefresh: true));
  }
}
