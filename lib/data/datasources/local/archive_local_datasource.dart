import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/archive_model.dart';

abstract class ArchiveLocalDataSource {
  Future<void> cacheArchives(String sessionId, List<ArchiveModel> archives);
  Future<List<ArchiveModel>> getCachedArchives(String sessionId);
  Future<void> clearSession(String sessionId);
  Future<void> clearAll();
}

class ArchiveLocalDataSourceImpl implements ArchiveLocalDataSource {
  final Box<dynamic> archiveBox;

  ArchiveLocalDataSourceImpl({required this.archiveBox});

  @override
  Future<void> cacheArchives(String sessionId, List<ArchiveModel> archives) async {
    try {
      final encoded = archives.map((a) => jsonEncode(a.toJson())).toList();
      await archiveBox.put(sessionId, encoded);
    } catch (e) {
      throw CacheException('Gagal menyimpan cache arsip: $e');
    }
  }

  @override
  Future<List<ArchiveModel>> getCachedArchives(String sessionId) async {
    try {
      final raw = archiveBox.get(sessionId);
      if (raw == null) return [];
      final list = raw as List;
      return list
          .whereType<String>()
          .map((s) => ArchiveModel.fromJson(Map<String, dynamic>.from(jsonDecode(s) as Map)))
          .toList();
    } catch (e) {
      throw CacheException('Gagal membaca cache arsip: $e');
    }
  }

  @override
  Future<void> clearSession(String sessionId) async {
    try {
      await archiveBox.delete(sessionId);
    } catch (e) {
      throw CacheException('Gagal membersihkan cache sesi: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await archiveBox.clear();
    } catch (e) {
      throw CacheException('Gagal membersihkan cache arsip: $e');
    }
  }
}
