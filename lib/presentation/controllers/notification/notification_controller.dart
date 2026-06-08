import 'package:kegiatin/domain/entities/notification_item.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/providers/notification_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_controller.g.dart';

@riverpod
class NotificationController extends _$NotificationController {
  @override
  FutureOr<List<NotificationItem>> build() async {
    return _loadNotifications();
  }

  Future<List<NotificationItem>> _loadNotifications() async {
    final useCase = ref.read(getNotificationsUseCaseProvider);
    final result = await useCase(const NoInput());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (notifications) => notifications,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadNotifications());
  }

  Future<void> addNotification(NotificationItem item) async {
    final useCase = ref.read(addNotificationUseCaseProvider);
    final result = await useCase(item);
    await result.fold(
      (failure) => throw Exception(failure.message),
      (_) => refresh(),
    );
  }

  Future<void> markAsRead(String id) async {
    final useCase = ref.read(markNotificationReadUseCaseProvider);
    final result = await useCase(id);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Optimistic update
        if (state.hasValue) {
          final updatedList = state.value!.map((n) {
            if (n.id == id) {
              return NotificationItem(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                eventId: n.eventId,
                isRead: true,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
          state = AsyncValue.data(updatedList);
        }
      },
    );
  }

  Future<void> markAllAsRead() async {
    final useCase = ref.read(markAllNotificationsReadUseCaseProvider);
    final result = await useCase(const NoInput());
    await result.fold(
      (failure) => throw Exception(failure.message),
      (_) => refresh(),
    );
  }

  Future<void> deleteNotification(String id) async {
    final useCase = ref.read(deleteNotificationUseCaseProvider);
    final result = await useCase(id);
    await result.fold(
      (failure) => throw Exception(failure.message),
      (_) => refresh(),
    );
  }

  Future<void> clearAll() async {
    final useCase = ref.read(clearNotificationsUseCaseProvider);
    final result = await useCase(const NoInput());
    await result.fold(
      (failure) => throw Exception(failure.message),
      (_) => refresh(),
    );
  }
}
