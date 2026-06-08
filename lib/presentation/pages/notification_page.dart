import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/enums/notification_type.dart';
import 'package:kegiatin/domain/enums/user_role.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/controllers/notification/notification_controller.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final notificationState = ref.watch(notificationControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          KegiatinAppBar(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifikasi',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (notificationState.value?.isNotEmpty ?? false)
                  TextButton(
                    onPressed: () {
                      ref.read(notificationControllerProvider.notifier).markAllAsRead();
                    },
                    child: Text(
                      'Tandai Semua Dibaca',
                      style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: notificationState.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada notifikasi',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(notificationControllerProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: colorScheme.onError),
                        ),
                        onDismissed: (direction) {
                          ref.read(notificationControllerProvider.notifier).deleteNotification(item.id);
                        },
                        child: InkWell(
                          onTap: () {
                            if (!item.isRead) {
                              ref.read(notificationControllerProvider.notifier).markAsRead(item.id);
                            }
                            if (item.eventId != null) {
                              final isAdmin = authState.value?.role == UserRole.admin;
                              if (isAdmin) {
                                context.push('/admin/event-detail/${item.eventId}');
                              } else {
                                context.push('/peserta/event-detail/${item.eventId}');
                              }
                            }
                          },
                          child: Container(
                            color: item.isRead
                                ? Colors.transparent
                                : colorScheme.primaryContainer.withValues(alpha: 0.3),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildIcon(item.type, colorScheme),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.body,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        timeago.format(item.createdAt, locale: 'id'),
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!item.isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(NotificationType type, ColorScheme colorScheme) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.eventCreated:
        iconData = Icons.event_available;
        color = colorScheme.primary;
        break;
      case NotificationType.sessionUpdated:
        iconData = Icons.update;
        color = colorScheme.secondary;
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        color = colorScheme.tertiary;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color),
    );
  }
}
