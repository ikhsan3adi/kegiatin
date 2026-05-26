import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/rsvp_model.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';

abstract class RsvpRemoteDataSource {
  /// Membuat RSVP baru: `POST /events/{eventId}/rsvp`.
  Future<RsvpModel> createRsvp(String eventId);

  /// Mengundang user ke event (Admin): `POST /events/{eventId}/rsvp/invite`.
  Future<RsvpModel> inviteUser(String eventId, String userId);

  /// Mengambil RSVP milik user yang sedang login: `GET /rsvp/me`.
  Future<PaginatedResult<RsvpModel>> getMyRsvps({int page = 1, int limit = 20});

  /// Mengambil daftar peserta RSVP per event (Admin): `GET /events/{eventId}/rsvp`.
  Future<PaginatedResult<RsvpWithUser>> getEventRsvps(
    String eventId, {
    int page = 1,
    int limit = 100,
    String? search,
  });
}

class RsvpRemoteDataSourceImpl implements RsvpRemoteDataSource {
  final Dio dio;

  RsvpRemoteDataSourceImpl(this.dio);

  Map<String, dynamic> _asMap(dynamic value) => Map<String, dynamic>.from(value as Map);

  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final message = _asMap(data)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return e.message ?? fallback;
  }

  @override
  Future<RsvpModel> createRsvp(String eventId) async {
    try {
      final response = await dio.post(ApiConstants.eventRsvp(eventId));
      final body = _asMap(response.data);
      return RsvpModel.fromJson(_asMap(body['data']));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mendaftar ke kegiatan'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<RsvpModel> inviteUser(String eventId, String userId) async {
    try {
      final response = await dio.post(
        ApiConstants.eventRsvpInvite(eventId),
        data: {'userId': userId},
      );
      final body = _asMap(response.data);
      return RsvpModel.fromJson(_asMap(body['data']));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengundang anggota'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PaginatedResult<RsvpModel>> getMyRsvps({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        ApiConstants.myRsvps,
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = _asMap(response.data);
      final data = (body['data'] as List).map((item) => RsvpModel.fromJson(_asMap(item))).toList();
      final meta = _asMap(body['meta']);
      return PaginatedResult<RsvpModel>(
        data: data,
        total: meta['total'] as int,
        page: meta['page'] as int,
        limit: meta['limit'] as int,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengambil daftar RSVP'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PaginatedResult<RsvpWithUser>> getEventRsvps(
    String eventId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      final response = await dio.get(
        ApiConstants.eventRsvpList(eventId),
        queryParameters: queryParams,
      );
      final body = _asMap(response.data);
      final data = (body['data'] as List).map((item) {
        final itemMap = _asMap(item);
        final userMap = _asMap(itemMap['user']);
        return RsvpWithUser(
          id: itemMap['id'] as String,
          userId: itemMap['userId'] as String,
          eventId: itemMap['eventId'] as String,
          qrToken: itemMap['qrToken'] as String,
          status: RsvpStatus.values.firstWhere(
            (e) => e.name.toUpperCase() == (itemMap['status'] as String).toUpperCase(),
          ),
          createdAt: DateTime.parse(itemMap['createdAt'] as String),
          user: UserSummary(
            id: itemMap['userId'] as String,
            displayName: userMap['displayName'] as String? ?? '',
            npa: userMap['npa'] as String?,
            cabang: userMap['cabang'] as String?,
            photoUrl: userMap['photoUrl'] as String?,
          ),
        );
      }).toList();
      final meta = _asMap(body['meta']);
      return PaginatedResult<RsvpWithUser>(
        data: data,
        total: meta['total'] as int,
        page: meta['page'] as int,
        limit: meta['limit'] as int,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengambil daftar peserta RSVP'),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
