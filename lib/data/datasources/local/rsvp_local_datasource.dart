import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/rsvp_model.dart';

abstract class RsvpLocalDataSource {
  Future<void> cacheRsvp(RsvpModel rsvp);
  Future<RsvpModel?> getRsvpByEventId(String eventId);
  Future<List<RsvpModel>> getAllCachedRsvps();
  Future<void> removeRsvp(String eventId);
  Future<void> clearAll();
}

class RsvpLocalDataSourceImpl implements RsvpLocalDataSource {
  final Box<dynamic> rsvpBox;

  RsvpLocalDataSourceImpl({required this.rsvpBox});

  @override
  Future<void> cacheRsvp(RsvpModel rsvp) async {
    try {
      await rsvpBox.put(rsvp.eventId, jsonEncode(rsvp.toJson()));
    } catch (e) {
      throw CacheException('Gagal menyimpan RSVP: $e');
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
  Future<List<RsvpModel>> getAllCachedRsvps() async {
    try {
      final values = rsvpBox.values;
      final list = <RsvpModel>[];
      for (final raw in values) {
        if (raw is String) {
          list.add(RsvpModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
        }
      }
      return list;
    } catch (e) {
      throw CacheException('Gagal membaca semua RSVP: $e');
    }
  }

  @override
  Future<void> removeRsvp(String eventId) async {
    try {
      await rsvpBox.delete(eventId);
    } catch (e) {
      throw CacheException('Gagal menghapus RSVP: $e');
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
