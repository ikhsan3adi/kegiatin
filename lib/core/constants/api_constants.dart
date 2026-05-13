import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh';

  // Events
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';
  static String publishEvent(String id) => '/events/$id/publish';
  static String cancelEvent(String id) => '/events/$id/cancel';
  static String startEvent(String id) => '/events/$id/start';
  static String completeEvent(String id) => '/events/$id/complete';
  static String eventSessions(String id) => '/events/$id/sessions';

  // RSVP
  static String eventRsvp(String eventId) => '/events/$eventId/rsvp';
  static String cancelRsvp(String rsvpId) => '/rsvp/$rsvpId';
  static String rsvpQr(String rsvpId) => '/rsvp/$rsvpId/qr';
  static const String myRsvps = '/rsvp/me';

  // Profile
  static const String profile = '/profile';
  static const String profileHistory = '/profile/history';
}
