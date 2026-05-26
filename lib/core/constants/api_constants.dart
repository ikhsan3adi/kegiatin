import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';

  static String resolveImageUrl(String url) {
    final uploadsIndex = url.indexOf('/uploads/');
    if (uploadsIndex != -1) {
      final relativePath = url.substring(uploadsIndex);
      final base = baseUrl.replaceAll('/api', '');
      return '$base$relativePath';
    }
    return url;
  }

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

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
  static String sessionById(String id) => '/sessions/$id';
  // RSVP
  static String eventRsvp(String eventId) => '/events/$eventId/rsvp';
  static String eventRsvpInvite(String eventId) => '/events/$eventId/rsvp/invite';
  static const String myRsvps = '/rsvp/me';
  static String eventRsvpList(String eventId) => '/events/$eventId/rsvp';
  // Attendance
  static const String attendanceScan = '/attendance/scan';
  static const String attendanceSync = '/attendance/sync';
  static const String attendanceLookup = '/attendance/lookup';
  static String sessionAttendance(String sessionId) => '/sessions/$sessionId/attendance';

  // Profile
  static const String profileMe = '/profile/me';
  static const String profileHistory = '/profile/history';

  // Archives
  static String sessionArchives(String sessionId) => '/sessions/$sessionId/archives';
  static String archiveById(String id) => '/archives/$id';

  // Uploads
  static const String uploadImage = '/uploads/image';

  // Users
  static const String usersSearch = '/users/search';
}
