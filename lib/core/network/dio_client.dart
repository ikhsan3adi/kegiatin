import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/data/datasources/local/auth_local_datasource.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  DioClient({required this.dio, required this.authLocalDataSource}) {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(milliseconds: ApiConstants.connectTimeout);
    dio.options.receiveTimeout = const Duration(milliseconds: ApiConstants.receiveTimeout);

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['ngrok-skip-browser-warning'] = 'true';
          final token = await authLocalDataSource.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode != 401) {
            return handler.next(e);
          }

          // Coba refresh token jika ada
          final storedRefreshToken = await authLocalDataSource.getRefreshToken();
          if (storedRefreshToken == null) {
            return handler.next(e);
          }

          try {
            final refreshResponse = await Dio().post(
              '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
              data: {'refreshToken': storedRefreshToken},
            );
            final responseData = refreshResponse.data as Map<String, dynamic>;
            final newAccessToken = responseData['accessToken'] as String;

            await authLocalDataSource.saveTokens(newAccessToken, storedRefreshToken);

            // Retry request awal dengan token baru
            final retryOptions = e.requestOptions
              ..headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } catch (refreshError) {
            log('Token refresh failed: $refreshError');
            await authLocalDataSource.clearAll();
            return handler.next(e);
          }
        },
      ),
    );
  }
}
