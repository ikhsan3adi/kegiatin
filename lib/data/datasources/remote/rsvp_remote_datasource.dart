import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/rsvp_model.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';

abstract class RsvpRemoteDataSource {
  /// Membuat RSVP baru: `POST /events/{eventId}/rsvp`.
  Future<RsvpModel> createRsvp(String eventId);

  /// Mengambil RSVP milik user yang sedang login: `GET /rsvp/me`.
  Future<PaginatedResult<RsvpModel>> getMyRsvps({int page = 1, int limit = 20});
}

class RsvpRemoteDataSourceImpl implements RsvpRemoteDataSource {
  final Dio dio;

  RsvpRemoteDataSourceImpl(this.dio);

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

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
  Future<PaginatedResult<RsvpModel>> getMyRsvps({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.myRsvps,
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = _asMap(response.data);
      final data = (body['data'] as List)
          .map((item) => RsvpModel.fromJson(_asMap(item)))
          .toList();
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
}
