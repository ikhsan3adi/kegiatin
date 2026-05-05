import 'package:dio/dio.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/models/event_model.dart';
import 'package:kegiatin/data/models/session_model.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';

abstract class EventRemoteDataSource {
  /// Membuat kegiatan baru beserta sesi-sesinya.
  ///
  /// Melempar [ServerException] jika request gagal.
  Future<EventModel> createEvent(CreateEventInput input);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl(this.dio);

  @override
  Future<EventModel> createEvent(CreateEventInput input) async {
    try {
      final response = await dio.post(
        ApiConstants.events,
        data: {
          'title': input.title,
          'description': input.description,
          'type': _eventTypeToJson(input.type),
          'visibility': _visibilityToJson(input.visibility),
          'location': input.location,
          'contactPerson': input.contactPerson,
          'sessions': input.sessions
              .map(
                (s) => {
                  'title': s.title,
                  'startTime': s.startTime.toIso8601String(),
                  'endTime': s.endTime.toIso8601String(),
                  if (s.location != null) 'location': s.location,
                  if (s.capacity != null) 'capacity': s.capacity,
                },
              )
              .toList(),
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData['data'] as Map<String, dynamic>;

      final eventJson = payload['event'] as Map<String, dynamic>;
      final sessionsJson = payload['sessions'] as List<dynamic>;

      final sessions = sessionsJson
          .map((s) => SessionModel.fromJson(s as Map<String, dynamic>))
          .toList();

      return EventModel.fromJson(eventJson).copyWith(sessions: sessions);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException();
      }
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data['message'] : null;
      throw ServerException(
        message ?? 'Gagal membuat kegiatan',
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _eventTypeToJson(EventType type) => switch (type) {
        EventType.single => 'SINGLE',
        EventType.series => 'SERIES',
      };

  String _visibilityToJson(EventVisibility visibility) => switch (visibility) {
        EventVisibility.open => 'OPEN',
        EventVisibility.inviteOnly => 'INVITE_ONLY',
      };
}
