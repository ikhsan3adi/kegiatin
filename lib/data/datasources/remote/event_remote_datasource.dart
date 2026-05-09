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
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl(this.dio);

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
        if (search != null) 'search': search,
      };

      final response = await dio.get(ApiConstants.events, queryParameters: queryParams);

      final data = (response.data['data'] as List)
          .map((json) {
            // Menangani struktur dari backend sementara (nested 'event' dan 'sessions')
            if (json.containsKey('event') && json.containsKey('sessions')) {
              final eventJson = Map<String, dynamic>.from(json['event']);
              eventJson['sessions'] = json['sessions'];
              return EventModel.fromJson(eventJson);
            }
            return EventModel.fromJson(json);
          })
          .toList();
          
      final meta = response.data['meta'];

      return PaginatedResult<EventModel>(
        data: data,
        total: meta['total'],
        page: meta['page'],
        limit: meta['limit'],
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Terjadi kesalahan saat mengambil events',
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
      return EventModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Gagal mengambil event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> createEvent(CreateEventInput input) async {
    try {
      // NOTE: Sesuaikan dengan struktur JSON yang diinginkan CreateEventDto
      final data = {
        'title': input.title,
        'description': input.description,
        'type': input.type.toJson(),
        'visibility': input.visibility.toJson(),
        'location': input.location,
        'contactPerson': input.contactPerson,
        'imageUrl': input.imageUrl,
        'sessions': input.sessions.map((s) => {
          'title': s.title,
          'startTime': s.startTime.toIso8601String(),
          'endTime': s.endTime.toIso8601String(),
          'location': s.location,
          'capacity': s.capacity,
        }).toList(),
      };

      final response = await dio.post(ApiConstants.events, data: data);
      return EventModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Gagal membuat event',
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
      };

      final response = await dio.patch(ApiConstants.eventById(id), data: data);
      return EventModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Gagal mengupdate event',
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
        e.response?.data['message'] ?? e.message ?? 'Gagal menghapus event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> publishEvent(String id) async {
    try {
      await dio.patch(ApiConstants.publishEvent(id));
      // Fetch ulang karena backend return void
      final response = await dio.get(ApiConstants.eventById(id));
      return EventModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Gagal mempublish event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> cancelEvent(String id) async {
    try {
      await dio.patch(ApiConstants.cancelEvent(id));
      // Fetch ulang karena backend return void
      final response = await dio.get(ApiConstants.eventById(id));
      return EventModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Gagal membatalkan event',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
