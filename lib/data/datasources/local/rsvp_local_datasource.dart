import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/rsvp_model.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';

abstract class RsvpLocalDataSource {
  Future<void> cacheRsvps(String eventId, List<RsvpWithUser> rsvps);
  Future<List<RsvpWithUser>> getCachedRsvps(String eventId);
  Future<void> cacheRsvp(RsvpModel rsvp);
  Future<List<RsvpModel>> getAllCachedRsvps();
  Future<bool> hasRsvp(String eventId, String userId);
  Future<RsvpModel?> getRsvpByEventId(String eventId);
  Future<RsvpWithUser?> getRsvpByQrToken(String qrToken);
  Future<void> removeRsvp(String eventId);
  Future<void> clearAll();
}

class RsvpLocalDataSourceImpl implements RsvpLocalDataSource {
  final Box<dynamic> rsvpBox;

  RsvpLocalDataSourceImpl({required this.rsvpBox});

  static String _listKey(String eventId) => '${eventId}_list';

  Map<String, dynamic> _rsvpWithUserToJson(RsvpWithUser r) => {
    'id': r.id,
    'userId': r.userId,
    'eventId': r.eventId,
    'qrToken': r.qrToken,
    'status': r.status.name,
    'createdAt': r.createdAt.toIso8601String(),
    'user': {
      'id': r.user.id,
      'displayName': r.user.displayName,
      'npa': r.user.npa,
      'cabang': r.user.cabang,
      'photoUrl': r.user.photoUrl,
    },
  };

  RsvpWithUser _rsvpWithUserFromJson(Map<String, dynamic> json) => RsvpWithUser(
    id: json['id'] as String,
    userId: json['userId'] as String,
    eventId: json['eventId'] as String,
    qrToken: json['qrToken'] as String,
    status: RsvpStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == (json['status'] as String).toUpperCase(),
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    user: UserSummary(
      id: (json['user'] as Map)['id'] as String? ?? json['userId'] as String,
      displayName: (json['user'] as Map)['displayName'] as String? ?? '',
      npa: (json['user'] as Map)['npa'] as String?,
      cabang: (json['user'] as Map)['cabang'] as String?,
      photoUrl: (json['user'] as Map)['photoUrl'] as String?,
    ),
  );

  @override
  Future<void> cacheRsvps(String eventId, List<RsvpWithUser> rsvps) async {
    try {
      final encoded = rsvps.map((r) => jsonEncode(_rsvpWithUserToJson(r))).toList();
      await rsvpBox.put(_listKey(eventId), encoded);
    } catch (e) {
      throw CacheException('Gagal menyimpan cache RSVP: $e');
    }
  }

  @override
  Future<List<RsvpWithUser>> getCachedRsvps(String eventId) async {
    try {
      final raw = rsvpBox.get(_listKey(eventId));
      if (raw == null) return [];
      final list = raw as List;
      return list
          .whereType<String>()
          .map((s) => _rsvpWithUserFromJson(Map<String, dynamic>.from(jsonDecode(s) as Map)))
          .toList();
    } catch (e) {
      throw CacheException('Gagal membaca cache RSVP: $e');
    }
  }

  @override
  Future<RsvpWithUser?> getRsvpByQrToken(String qrToken) async {
    try {
      final keys = rsvpBox.keys;
      for (final key in keys) {
        if (key is String && key.endsWith('_list')) {
          final raw = rsvpBox.get(key);
          if (raw is List) {
            for (final s in raw) {
              if (s is String) {
                final decoded = Map<String, dynamic>.from(jsonDecode(s) as Map);
                if (decoded['qrToken'] == qrToken) {
                  return _rsvpWithUserFromJson(decoded);
                }
              }
            }
          }
        }
      }
      return null;
    } catch (_) {
      return null;
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
