import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/archive_model.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';

abstract class ArchiveRemoteDataSource {
  Future<ArchiveModel> createArchive({
    required String sessionId,
    required String title,
    required ArchiveType type,
    required String fileUrl,
  });
  Future<List<ArchiveModel>> getArchives(String sessionId);
  Future<void> deleteArchive(String id);
}

class ArchiveRemoteDataSourceImpl implements ArchiveRemoteDataSource {
  final Dio dio;

  ArchiveRemoteDataSourceImpl(this.dio);

  Map<String, dynamic> _asMap(dynamic value) => Map<String, dynamic>.from(value as Map);

  @override
  Future<ArchiveModel> createArchive({
    required String sessionId,
    required String title,
    required ArchiveType type,
    required String fileUrl,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.sessionArchives(sessionId),
        data: {'title': title, 'type': type.toJson(), 'fileUrl': fileUrl},
      );
      final body = _asMap(response.data);
      final data = _asMap(body['data']);
      return ArchiveModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal membuat materi'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ArchiveModel>> getArchives(String sessionId) async {
    try {
      final response = await dio.get(ApiConstants.sessionArchives(sessionId));
      final body = _asMap(response.data);
      final data = (body['data'] as List).map((json) {
        return ArchiveModel.fromJson(_asMap(json));
      }).toList();
      return data;
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengambil daftar materi'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteArchive(String id) async {
    try {
      await dio.delete(ApiConstants.archiveById(id));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal menghapus materi'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = _asMap(data)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return e.message ?? fallback;
  }
}
