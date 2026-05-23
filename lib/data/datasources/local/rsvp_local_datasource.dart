import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/rsvp_model.dart';

abstract class RsvpLocalDataSource {
  Future<void> cacheRsvps(String eventId, List<RsvpModel> rsvps);
  Future<List<RsvpModel>> getCachedRsvps(String eventId);
  Future<void> cacheRsvp(RsvpModel rsvp);
  Future<List<RsvpModel>> getAllCachedRsvps();
  Future<bool> hasRsvp(String eventId, String userId);
  Future<RsvpModel?> getRsvpByEventId(String eventId);
  Future<void> removeRsvp(String eventId);
  Future<void> clearAll();
}

class RsvpLocalDataSourceImpl implements RsvpLocalDataSource {
  final Box<dynamic> rsvpBox;

  RsvpLocalDataSourceImpl({required this.rsvpBox});

  static String _listKey(String eventId) => '${eventId}_list';

  @override
  Future<void> cacheRsvps(String eventId, List<RsvpModel> rsvps) async {
    try {
      final encoded = rsvps.map((r) => jsonEncode(r.toJson())).toList();
      await rsvpBox.put(_listKey(eventId), encoded);
    } catch (e) {
      throw CacheException('Gagal menyimpan cache RSVP: $e');
    }
  }

  @override
  Future<List<RsvpModel>> getCachedRsvps(String eventId) async {
    try {
      final raw = rsvpBox.get(_listKey(eventId));
      if (raw == null) return [];
      final list = raw as List;
      return list
          .whereType<String>()
          .map((s) => RsvpModel.fromJson(Map<String, dynamic>.from(jsonDecode(s) as Map)))
          .toList();
    } catch (e) {
      throw CacheException('Gagal membaca cache RSVP: $e');
    }
  }

  @override
  Future<bool> hasRsvp(String eventId, String userId) async {
    try {
      final rsvps = await getCachedRsvps(eventId);
      return rsvps.any((r) => r.userId == userId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> cacheRsvp(RsvpModel rsvp) async {
    try {
      await rsvpBox.put(rsvp.eventId, jsonEncode(rsvp.toJson()));
    } catch (e) {
      throw CacheException('Gagal menyimpan RSVP: $e');
    }
  }

  @override
  Future<List<RsvpModel>> getAllCachedRsvps() async {
    try {
      final values = rsvpBox.values;
      final list = <RsvpModel>[];
      for (final raw in values) {
        if (raw is String) {
          final decoded = jsonDecode(raw);
          if (decoded is List) continue;
          list.add(RsvpModel.fromJson(Map<String, dynamic>.from(decoded as Map)));
        }
      }
      return list;
    } catch (e) {
      throw CacheException('Gagal membaca semua RSVP: $e');
    }
  }

  @override
  Future<RsvpModel?> getRsvpByEventId(String eventId) async {
    try {
      final raw = rsvpBox.get(eventId);
      if (raw == null) return null;
      return RsvpModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String) as Map));
    } catch (e) {
      throw CacheException('Gagal membaca RSVP: $e');
    }
  }

  @override
  Future<void> removeRsvp(String eventId) async {
    try {
      await rsvpBox.delete(_listKey(eventId));
    } catch (e) {
      throw CacheException('Gagal menghapus cache RSVP: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await rsvpBox.clear();
    } catch (e) {
      throw CacheException('Gagal membersihkan RSVP: $e');
    }
  }
}
