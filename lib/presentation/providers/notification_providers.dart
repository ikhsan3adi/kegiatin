import 'package:kegiatin/data/datasources/local/notification_local_datasource.dart';
import 'package:kegiatin/data/repositories/notification_repository_impl.dart';
import 'package:kegiatin/domain/repositories/notification_repository.dart';
import 'package:kegiatin/domain/usecases/notification/add_notification_usecase.dart';
import 'package:kegiatin/domain/usecases/notification/clear_notifications_usecase.dart';
import 'package:kegiatin/domain/usecases/notification/delete_notification_usecase.dart';
import 'package:kegiatin/domain/usecases/notification/get_notifications_usecase.dart';
import 'package:kegiatin/domain/usecases/notification/get_unread_count_usecase.dart';
import 'package:kegiatin/domain/usecases/notification/mark_all_notifications_read_usecase.dart';
import 'package:kegiatin/domain/usecases/notification/mark_notification_read_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationLocalDataSource notificationLocalDataSource(Ref ref) =>
    NotificationLocalDataSourceImpl(notificationBox: ref.watch(notificationBoxProvider));

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepositoryImpl(localDataSource: ref.watch(notificationLocalDataSourceProvider));

@Riverpod(keepAlive: true)
GetNotificationsUseCase getNotificationsUseCase(Ref ref) =>
    GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));

@Riverpod(keepAlive: true)
AddNotificationUseCase addNotificationUseCase(Ref ref) =>
    AddNotificationUseCase(ref.watch(notificationRepositoryProvider));

@Riverpod(keepAlive: true)
MarkNotificationReadUseCase markNotificationReadUseCase(Ref ref) =>
    MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider));

@Riverpod(keepAlive: true)
MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase(Ref ref) =>
    MarkAllNotificationsReadUseCase(ref.watch(notificationRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteNotificationUseCase deleteNotificationUseCase(Ref ref) =>
    DeleteNotificationUseCase(ref.watch(notificationRepositoryProvider));

@Riverpod(keepAlive: true)
ClearNotificationsUseCase clearNotificationsUseCase(Ref ref) =>
    ClearNotificationsUseCase(ref.watch(notificationRepositoryProvider));

@Riverpod(keepAlive: true)
GetUnreadCountUseCase getUnreadCountUseCase(Ref ref) =>
    GetUnreadCountUseCase(ref.watch(notificationRepositoryProvider));
