import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';

abstract class UploadsRemoteDataSource {
  Future<String> uploadImage(String filePath);
}

class UploadsRemoteDataSourceImpl implements UploadsRemoteDataSource {
  final Dio dio;

  UploadsRemoteDataSourceImpl(this.dio);

  MediaType? _getMediaType(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    final ext = dotIndex != -1 ? filePath.substring(dotIndex).toLowerCase() : '';
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.pdf':
        return MediaType('application', 'pdf');
      case '.txt':
        return MediaType('text', 'plain');
      case '.doc':
        return MediaType('application', 'msword');
      case '.docx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case '.xls':
        return MediaType('application', 'vnd.ms-excel');
      case '.xlsx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case '.ppt':
        return MediaType('application', 'vnd.ms-powerpoint');
      case '.pptx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.presentationml.presentation');
      case '.zip':
        return MediaType('application', 'zip');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      final mediaType = _getMediaType(filePath);
      final file = await MultipartFile.fromFile(
        filePath,
        contentType: mediaType,
      );
      final formData = FormData.fromMap({'file': file});
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
        _extractErrorMessage(e, 'Gagal mengunggah file'),
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
