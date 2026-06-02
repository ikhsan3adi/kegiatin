import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:kegiatin/domain/entities/update_profile_input.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfileInput input);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get(ApiConstants.profileMe);
      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(payload);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengambil data profil'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileInput input) async {
    try {
      final data = <String, dynamic>{};
      if (input.displayName != null) data['displayName'] = input.displayName;
      if (input.cabang != null) data['cabang'] = input.cabang;
      if (input.photoUrl != null) data['photoUrl'] = input.photoUrl;

      final response = await dio.patch(ApiConstants.profileMe, data: data);
      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(payload);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal memperbarui profil'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return e.message ?? fallback;
  }
}
