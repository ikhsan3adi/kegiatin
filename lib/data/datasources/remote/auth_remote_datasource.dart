import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/auth_response_model.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:kegiatin/domain/entities/register_input.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<UserModel> register(RegisterInput input);
  Future<UserModel> getCurrentUser();
  Future<String> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData['data'] as Map<String, dynamic>;
      return AuthResponseModel(
        user: UserModel.fromJson(payload['user'] as Map<String, dynamic>),
        accessToken: (payload['tokens'] as Map<String, dynamic>)['accessToken'] as String,
        refreshToken: (payload['tokens'] as Map<String, dynamic>)['refreshToken'] as String,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Email atau password salah');
      }
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data['message'] : null;
      throw ServerException(message ?? 'Gagal login', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UserModel> register(RegisterInput input) async {
    try {
      final response = await dio.post(ApiConstants.register, data: {
        'email': input.email,
        'password': input.password,
        'displayName': input.displayName,
        'userType': input.userType,
        if (input.npa != null) 'npa': input.npa,
      });
      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(payload);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data['message'] : null;
      throw ServerException(message ?? 'Gagal registrasi', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get(ApiConstants.me);
      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const UnauthorizedException();
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data['message'] : null;
      throw ServerException(message ?? 'Gagal mengambil data user', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData['data'] as Map<String, dynamic>;
      return payload['accessToken'] as String;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const UnauthorizedException('Sesi berakhir');
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data['message'] : null;
      throw ServerException(message ?? 'Gagal refresh token', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } catch (_) {
      // Tetap berhasil logout secara lokal walau request ke server gagal
    }
  }
}
