import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/session_model.dart';
import 'package:kegiatin/domain/entities/session_input.dart';

abstract class SessionRemoteDataSource {
  Future<SessionModel> addSession(String eventId, SessionInput input);
  Future<SessionModel> updateSession(
    String id, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? capacity,
  });
  Future<void> deleteSession(String id);
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final Dio dio;

  SessionRemoteDataSourceImpl(this.dio);

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
  Future<SessionModel> addSession(String eventId, SessionInput input) async {
    try {
      final response = await dio.post(
        ApiConstants.eventSessions(eventId),
        data: {
          'title': input.title,
          'startTime': input.startTime.toUtc().toIso8601String(),
          'endTime': input.endTime.toUtc().toIso8601String(),
          if (input.location != null) 'location': input.location,
          if (input.capacity != null) 'capacity': input.capacity,
        },
      );
      final body = _asMap(response.data);
      return SessionModel.fromJson(_asMap(body['data']));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal menambah sesi'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<SessionModel> updateSession(
    String id, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? capacity,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': ?title,
        'startTime': ?startTime?.toUtc().toIso8601String(),
        'endTime': ?endTime?.toUtc().toIso8601String(),
        'location': ?location,
        'capacity': ?capacity,
      };
      final response = await dio.patch(ApiConstants.sessionById(id), data: data);
      final body = _asMap(response.data);
      return SessionModel.fromJson(_asMap(body['data']));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengupdate sesi'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      await dio.delete(ApiConstants.sessionById(id));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal menghapus sesi'),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
