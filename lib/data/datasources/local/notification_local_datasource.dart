import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getAllNotifications();
  Future<void> addNotification(NotificationModel item);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> clearAll();
  Future<int> getUnreadCount();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Box<dynamic> notificationBox;

  NotificationLocalDataSourceImpl({required this.notificationBox});

  static const String _notificationsKey = 'notifications_list';

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final raw = notificationBox.get(_notificationsKey);
      if (raw == null) return [];
      final list = raw as List;
      return list
          .whereType<String>()
          .map((s) => NotificationModel.fromJson(Map<String, dynamic>.from(jsonDecode(s) as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw CacheException('Gagal membaca cache notifikasi: $e');
    }
  }

  Future<void> _saveAll(List<NotificationModel> list) async {
    final encoded = list.map((m) => jsonEncode(m.toJson())).toList();
    await notificationBox.put(_notificationsKey, encoded);
  }

  @override
  Future<void> addNotification(NotificationModel item) async {
    try {
      final list = await getAllNotifications();
      list.add(item);
      await _saveAll(list);
    } catch (e) {
      throw CacheException('Gagal menyimpan notifikasi: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final list = await getAllNotifications();
      final index = list.indexWhere((n) => n.id == id);
      if (index != -1) {
        list[index] = list[index].copyWith(isRead: true);
        await _saveAll(list);
      }
    } catch (e) {
      throw CacheException('Gagal update notifikasi: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final list = await getAllNotifications();
      final updatedList = list.map((n) => n.copyWith(isRead: true)).toList();
      await _saveAll(updatedList);
    } catch (e) {
      throw CacheException('Gagal update semua notifikasi: $e');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final list = await getAllNotifications();
      list.removeWhere((n) => n.id == id);
      await _saveAll(list);
    } catch (e) {
      throw CacheException('Gagal menghapus notifikasi: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await notificationBox.delete(_notificationsKey);
    } catch (e) {
      throw CacheException('Gagal membersihkan notifikasi: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final list = await getAllNotifications();
      return list.where((n) => !n.isRead).length;
    } catch (e) {
      throw CacheException('Gagal membaca count notifikasi: $e');
    }
  }
}
