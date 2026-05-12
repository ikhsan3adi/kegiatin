import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/event_model.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';

abstract class EventRemoteDataSource {
  Future<PaginatedResult<EventModel>> getEvents({
    int page = 1,
    int limit = 10,
    EventStatus? status,
    EventType? type,
    String? search,
  });
  Future<EventModel> getEventById(String id);
  Future<EventModel> createEvent(CreateEventInput input);
  Future<EventModel> updateEvent(String id, UpdateEventInput input);
  Future<void> deleteEvent(String id);
  Future<EventModel> publishEvent(String id);
  Future<EventModel> cancelEvent(String id);
  Future<EventModel> startEvent(String id);
  Future<EventModel> completeEvent(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl(this.dio);

  Map<String, dynamic> _asMap(dynamic value) => Map<String, dynamic>.from(value as Map);

  String _extractErrorMessage(DioException e, String fallbackMessage) {
    final responseData = e.response?.data;
    if (responseData is Map) {
      final mapData = _asMap(responseData);
      final message = mapData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return e.message ?? fallbackMessage;
  }

  EventModel _eventFromResponse(Response<dynamic> response) {
    final responseBody = _asMap(response.data);
    final eventData = _asMap(responseBody['data']);
    return EventModel.fromJson(eventData);
  }

  @override
  Future<PaginatedResult<EventModel>> getEvents({
    int page = 1,
    int limit = 10,
    EventStatus? status,
    EventType? type,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.toJson(),
        if (type != null) 'type': type.toJson(),
        'search': ?search,
      };

      final response = await dio.get(ApiConstants.events, queryParameters: queryParams);

      final responseBody = _asMap(response.data);
      final data = (responseBody['data'] as List).map((json) {
        final item = _asMap(json);
        return EventModel.fromJson(item);
      }).toList();

      final meta = _asMap(responseBody['meta']);

      return PaginatedResult<EventModel>(
        data: data,
        total: meta['total'],
        page: meta['page'],
        limit: meta['limit'],
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Terjadi kesalahan saat mengambil events'),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Terjadi kesalahan yang tidak diketahui: $e');
    }
  }

  @override
  Future<EventModel> getEventById(String id) async {
    try {
      final response = await dio.get(ApiConstants.eventById(id));
      return _eventFromResponse(response);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengambil event'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> createEvent(CreateEventInput input) async {
    try {
      final data = {
        'title': input.title,
        'description': input.description,
        'type': input.type.toJson(),
        'visibility': input.visibility.toJson(),
        'location': input.location,
        'contactPerson': input.contactPerson,
        'imageUrl': input.imageUrl,
        'maxParticipants': input.maxParticipants,
        'sessions': input.sessions
            .map(
              (s) => {
                'title': s.title,
                'startTime': s.startTime.toIso8601String(),
                'endTime': s.endTime.toIso8601String(),
                'location': s.location,
                'capacity': s.capacity,
              },
            )
            .toList(),
      };

      final response = await dio.post(ApiConstants.events, data: data);
      return _eventFromResponse(response);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal membuat event'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> updateEvent(String id, UpdateEventInput input) async {
    try {
      final data = {
        if (input.title != null) 'title': input.title,
        if (input.description != null) 'description': input.description,
        if (input.visibility != null) 'visibility': input.visibility!.toJson(),
        if (input.location != null) 'location': input.location,
        if (input.contactPerson != null) 'contactPerson': input.contactPerson,
        if (input.imageUrl != null) 'imageUrl': input.imageUrl,
        if (input.maxParticipants != null) 'maxParticipants': input.maxParticipants,
      };

      final response = await dio.patch(ApiConstants.eventById(id), data: data);
      return _eventFromResponse(response);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mengupdate event'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await dio.delete(ApiConstants.eventById(id));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal menghapus event'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> publishEvent(String id) async {
    try {
      await dio.patch(ApiConstants.publishEvent(id));

      final response = await dio.get(ApiConstants.eventById(id));
      return _eventFromResponse(response);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal mempublish event'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> cancelEvent(String id) async {
    try {
      await dio.patch(ApiConstants.cancelEvent(id));

      final response = await dio.get(ApiConstants.eventById(id));
      return _eventFromResponse(response);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal membatalkan event'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> startEvent(String id) async {
    try {
      await dio.patch(ApiConstants.startEvent(id));

      final response = await dio.get(ApiConstants.eventById(id));
      return _eventFromResponse(response);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal memulai event'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> completeEvent(String id) async {
    try {
      await dio.patch(ApiConstants.completeEvent(id));

      final response = await dio.get(ApiConstants.eventById(id));
      return _eventFromResponse(response);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e, 'Gagal menyelesaikan event'),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
