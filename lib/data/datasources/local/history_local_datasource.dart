import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/activity_record_model.dart';

abstract class HistoryLocalDataSource {
  Future<void> cacheHistory(String key, List<ActivityRecordModel> records);
  Future<List<ActivityRecordModel>> getCachedHistory(String key);
  Future<void> clearAll();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final Box<dynamic> profileBox;

  HistoryLocalDataSourceImpl({required this.profileBox});

  static const String _historyKey = 'activity_history';

  @override
  Future<void> cacheHistory(String key, List<ActivityRecordModel> records) async {
    try {
      final encoded = records.map((r) => jsonEncode(r.toJson())).toList();
      await profileBox.put('${_historyKey}_$key', encoded);
    } catch (e) {
      throw CacheException('Gagal menyimpan cache riwayat: $e');
    }
  }

  @override
  Future<List<ActivityRecordModel>> getCachedHistory(String key) async {
    try {
      final raw = profileBox.get('${_historyKey}_$key');
      if (raw == null) return [];
      final list = raw as List;
      return list
          .whereType<String>()
          .map((s) => ActivityRecordModel.fromJson(Map<String, dynamic>.from(jsonDecode(s) as Map)))
          .toList();
    } catch (e) {
      throw CacheException('Gagal membaca cache riwayat: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await profileBox.clear();
    } catch (e) {
      throw CacheException('Gagal membersihkan cache profil: $e');
    }
  }
}
