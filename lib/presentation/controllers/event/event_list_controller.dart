import 'dart:async';

import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/usecases/get_events_usecase.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/user_role.dart';
import 'package:kegiatin/domain/entities/notification_item.dart';
import 'package:kegiatin/domain/enums/notification_type.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/controllers/notification/notification_controller.dart';
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
    final useCase = ref.read(getEventsUseCaseProvider);

    final currentStatus = status;
    EventStatus? eventStatus;
    if (currentStatus != null) {
      eventStatus = EventStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == currentStatus.toUpperCase(),
        orElse: () => EventStatus.published,
      );
    }

    final currentType = type;
    EventType? eventType;
    if (currentType != null) {
      eventType = EventType.values.firstWhere(
        (e) => e.name.toUpperCase() == currentType.toUpperCase(),
        orElse: () => EventType.single,
      );
    }

    final result = await useCase(
      GetEventsUseCaseParams(
        page: page,
        limit: limit,
        search: search,
        status: eventStatus,
        type: eventType,
      ),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) {
        unawaited(_triggerNotificationsIfNeeded(data.data));
        return data;
      },
    );
  }

  Future<void> refresh() async {
    final useCase = ref.read(getEventsUseCaseProvider);
    final currentStatus = status;
    EventStatus? eventStatus;
    if (currentStatus != null) {
      eventStatus = EventStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == currentStatus.toUpperCase(),
        orElse: () => EventStatus.published,
      );
    }
    final currentType = type;
    EventType? eventType;
    if (currentType != null) {
      eventType = EventType.values.firstWhere(
        (e) => e.name.toUpperCase() == currentType.toUpperCase(),
        orElse: () => EventType.single,
      );
    }
    final result = await useCase(
      GetEventsUseCaseParams(
        page: page,
        limit: limit,
        search: search,
        status: eventStatus,
        type: eventType,
        forceRefresh: true,
      ),
    );
    state = result.fold(
      (failure) => AsyncError(Exception(failure.message), StackTrace.current),
      (data) {
        unawaited(_triggerNotificationsIfNeeded(data.data));
        return AsyncData(data);
      },
    );
  }

  Future<void> _triggerNotificationsIfNeeded(List<Event> newEvents) async {
    final authState = ref.read(authControllerProvider).value;
    if (authState?.role != UserRole.member) return;

    try {
      final localDs = ref.read(notificationLocalDataSourceProvider);
      final notifications = await localDs.getAllNotifications();
      final notifiedEventIds = notifications.map((n) => n.eventId).toSet();
      // Only notify for events created after user registration (with 5 min buffer)
      final userCreatedAt = authState?.createdAt ?? DateTime.now().subtract(const Duration(days: 1));

      bool hasNew = false;
      for (final newEvent in newEvents) {
        if (newEvent.status == EventStatus.published && 
            !notifiedEventIds.contains(newEvent.id) &&
            newEvent.createdAt.isAfter(userCreatedAt.subtract(const Duration(minutes: 5)))) {
          
          final notif = NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + newEvent.id,
            type: NotificationType.eventCreated,
            title: 'Kegiatan Baru: ${newEvent.title}',
            body: 'Kegiatan baru telah diterbitkan. Yuk cek detailnya!',
            eventId: newEvent.id,
            isRead: false,
            createdAt: DateTime.now(),
          );
          await ref.read(addNotificationUseCaseProvider).call(notif);
          hasNew = true;
        }
      }

      if (hasNew) {
        await ref.read(notificationControllerProvider.notifier).refresh();
      }
    } catch (e) {
      // ignore silently to not break event list
    }
  }
}
