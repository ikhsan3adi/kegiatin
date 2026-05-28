import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/event_model.dart';

abstract class EventLocalDataSource {
  Future<void> cacheEvents(List<EventModel> events);
  Future<List<EventModel>> getCachedEvents();
  Future<void> cacheEvent(EventModel event);
  Future<EventModel?> getCachedEventById(String id);
  Future<void> clearAll();
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final Box<dynamic> eventCacheBox;

  EventLocalDataSourceImpl({required this.eventCacheBox});

  static const String _eventListKey = '_event_list_cache';

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    try {
      for (final event in events) {
        await eventCacheBox.put(event.id, jsonEncode(event.toJson()));
      }
    } catch (e) {
      throw CacheException('Gagal menyimpan cache events: $e');
    }
  }

  @override
  Future<List<EventModel>> getCachedEvents() async {
    try {
      final list = <EventModel>[];
      for (final key in eventCacheBox.keys) {
        if (key is String && key != _eventListKey) {
          final raw = eventCacheBox.get(key);
          if (raw is String) {
            list.add(EventModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
          }
        }
      }

      // Fallback for legacy list cache if individual cache is empty
      if (list.isEmpty) {
        final rawList = eventCacheBox.get(_eventListKey);
        if (rawList is List) {
          final legacyList = rawList
              .whereType<String>()
              .map((s) => EventModel.fromJson(Map<String, dynamic>.from(jsonDecode(s) as Map)))
              .toList();
          // Cache them individually for future accesses
          await cacheEvents(legacyList);
          list.addAll(legacyList);
        }
      }

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      throw CacheException('Gagal membaca cache events: $e');
    }
  }

  @override
  Future<void> cacheEvent(EventModel event) async {
    try {
      await eventCacheBox.put(event.id, jsonEncode(event.toJson()));
    } catch (e) {
      throw CacheException('Gagal menyimpan cache event: $e');
    }
  }

  @override
  Future<EventModel?> getCachedEventById(String id) async {
    try {
      final raw = eventCacheBox.get(id);
      if (raw == null) return null;
      return EventModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String) as Map));
    } catch (e) {
      throw CacheException('Gagal membaca cache event: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await eventCacheBox.clear();
    } catch (e) {
      throw CacheException('Gagal membersihkan cache events: $e');
    }
  }
}
