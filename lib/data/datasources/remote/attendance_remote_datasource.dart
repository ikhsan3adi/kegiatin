import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/attendance_lookup_model.dart';
import 'package:kegiatin/data/models/attendance_model.dart';
import 'package:kegiatin/data/models/sync_result_model.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> scanQr({required String qrToken, required String sessionId});

  Future<SyncResultResponse> syncBatch(List<SyncAttendanceRecord> records);

  Future<AttendanceLookupResponse> lookupQr({required String qrToken, required String sessionId});

  Future<PaginatedResult<AttendanceModel>> getSessionAttendance(
    String sessionId, {
    int page = 1,
    int limit = 100,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl(this.dio);

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
  Future<AttendanceModel> scanQr({required String qrToken, required String sessionId}) async {
    try {
      final response = await dio.post(
        ApiConstants.attendanceScan,
        data: {'qrToken': qrToken, 'sessionId': sessionId},
      );
      final body = _asMap(response.data);
      return AttendanceModel.fromJson(_asMap(body['data']));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal scan QR'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<SyncResultResponse> syncBatch(List<SyncAttendanceRecord> records) async {
    try {
      final response = await dio.post(
        ApiConstants.attendanceSync,
        data: SyncAttendanceBatchRequest(records: records).toJson(),
      );
      final body = _asMap(response.data);
      return SyncResultResponse.fromJson(_asMap(body['data']));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal sync attendance'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AttendanceLookupResponse> lookupQr({
    required String qrToken,
    required String sessionId,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.attendanceLookup,
        queryParameters: {'qrToken': qrToken, 'sessionId': sessionId},
      );
      final body = _asMap(response.data);
      return AttendanceLookupResponse.fromJson(_asMap(body['data']));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal lookup QR'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PaginatedResult<AttendanceModel>> getSessionAttendance(
    String sessionId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.sessionAttendance(sessionId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = _asMap(response.data);
      final data = (body['data'] as List)
          .map((item) => AttendanceModel.fromJson(_asMap(item)))
          .toList();
      final meta = _asMap(body['meta']);
      return PaginatedResult<AttendanceModel>(
        data: data,
        total: meta['total'] as int,
        page: meta['page'] as int,
        limit: meta['limit'] as int,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengambil daftar hadir'),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
