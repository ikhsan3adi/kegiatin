import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/attendance_model.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';

abstract class AttendanceLocalDataSource {
  Future<void> saveRecord(AttendanceModel record);
  Future<List<AttendanceModel>> getPendingRecords();
  Future<List<AttendanceModel>> getRecordsBySession(String sessionId);
  Future<void> updateSyncStatus(String localId, SyncStatus newStatus);
  Future<bool> isDuplicate(String userId, String sessionId);
  Future<bool> isDuplicateByQrToken(String qrToken, String sessionId);
  Future<void> clearAll();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final Box<dynamic> attendanceBox;

  AttendanceLocalDataSourceImpl({required this.attendanceBox});

  @override
  Future<void> saveRecord(AttendanceModel record) async {
    try {
      await attendanceBox.put(record.id, jsonEncode(record.toJson()));
    } catch (e) {
      throw CacheException('Gagal menyimpan attendance: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getPendingRecords() async {
    try {
      final values = attendanceBox.values;
      final list = <AttendanceModel>[];
      for (final raw in values) {
        if (raw is String) {
          final model = AttendanceModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
          if (model.syncStatus == SyncStatus.pending) {
            list.add(model);
          }
        }
      }
      return list;
    } catch (e) {
      throw CacheException('Gagal membaca pending attendance: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getRecordsBySession(String sessionId) async {
    try {
      final values = attendanceBox.values;
      final list = <AttendanceModel>[];
      for (final raw in values) {
        if (raw is String) {
          final model = AttendanceModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
          if (model.sessionId == sessionId) {
            list.add(model);
          }
        }
      }
      return list;
    } catch (e) {
      throw CacheException('Gagal membaca attendance by session: $e');
    }
  }

  @override
  Future<void> updateSyncStatus(String localId, SyncStatus newStatus) async {
    try {
      final raw = attendanceBox.get(localId);
      if (raw == null) return;
      final model = AttendanceModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw as String) as Map),
      );
      await attendanceBox.put(localId, jsonEncode(model.copyWith(syncStatus: newStatus).toJson()));
    } catch (e) {
      throw CacheException('Gagal update sync status: $e');
    }
  }

  @override
  Future<bool> isDuplicate(String userId, String sessionId) async {
    try {
      final values = attendanceBox.values;
      for (final raw in values) {
        if (raw is String) {
          final model = AttendanceModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
          if (model.userId == userId && model.sessionId == sessionId) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      throw CacheException('Gagal cek duplikat attendance: $e');
    }
  }

  @override
  Future<bool> isDuplicateByQrToken(String qrToken, String sessionId) async {
    try {
      final values = attendanceBox.values;
      for (final raw in values) {
        if (raw is String) {
          final model = AttendanceModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
          if (model.qrToken == qrToken && model.sessionId == sessionId) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      throw CacheException('Gagal cek duplikat attendance by QR: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await attendanceBox.clear();
    } catch (e) {
      throw CacheException('Gagal bersihkan attendance: $e');
    }
  }
}
