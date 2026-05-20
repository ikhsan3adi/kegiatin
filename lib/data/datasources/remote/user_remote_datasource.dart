import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';

abstract class UserRemoteDataSource {
  Future<PaginatedResult<UserSummary>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<PaginatedResult<UserSummary>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.usersSearch,
        queryParameters: {'q': query, 'page': page, 'limit': limit},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = (body['data'] as List)
          .map((item) => _mapToUserSummary(Map<String, dynamic>.from(item as Map)))
          .toList();
      final meta = Map<String, dynamic>.from(body['meta'] as Map);
      return PaginatedResult<UserSummary>(
        data: data,
        total: meta['total'] as int,
        page: meta['page'] as int,
        limit: meta['limit'] as int,
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data is Map
            ? (Map<String, dynamic>.from(e.response!.data as Map)['message'] as String? ??
                  'Gagal mencari user')
            : 'Gagal mencari user',
        statusCode: e.response?.statusCode,
      );
    }
  }

  UserSummary _mapToUserSummary(Map<String, dynamic> json) => UserSummary(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    npa: json['npa'] as String?,
    cabang: json['cabang'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );
}
