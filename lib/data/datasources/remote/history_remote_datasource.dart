import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/activity_record_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<ActivityRecordModel>> getHistory({int page = 1, int limit = 20, String? search});
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio dio;

  HistoryRemoteDataSourceImpl(this.dio);

  Map<String, dynamic> _asMap(dynamic value) => Map<String, dynamic>.from(value as Map);

  @override
  Future<List<ActivityRecordModel>> getHistory({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = {'page': page, 'limit': limit, if (search != null) 'search': search};
      final response = await dio.get(ApiConstants.profileHistory, queryParameters: queryParams);
      final body = _asMap(response.data);
      final data = (body['data'] as List).map((json) {
        return ActivityRecordModel.fromJson(_asMap(json));
      }).toList();
      return data;
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengambil riwayat'),
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
