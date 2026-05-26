import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';

abstract class UploadsRemoteDataSource {
  Future<String> uploadImage(String filePath);
}

class UploadsRemoteDataSourceImpl implements UploadsRemoteDataSource {
  final Dio dio;

  UploadsRemoteDataSourceImpl(this.dio);

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(filePath)});
      final response = await dio.post(
        ApiConstants.uploadImage,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);
      return data['url'] as String;
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengunggah gambar'),
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
