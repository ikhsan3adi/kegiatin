/// Dependency injection — barrel entrypoint for all Riverpod DI modules.
///
/// Implementation is split by technical domain:
/// - [core_providers.dart] — prefs, Hive, network, Dio
/// - [auth_providers.dart] — auth stack & auth use cases
/// - [event_providers.dart] — event stack & event use cases
/// - [rsvp_providers.dart] — RSVP stack & RSVP use cases
library;

export 'archive_providers.dart';
export 'attendance_providers.dart';
export 'auth_providers.dart';
export 'core_providers.dart';
export 'event_providers.dart';
export 'history_providers.dart';
export 'notification_providers.dart';
export 'pcd_providers.dart';
export 'rsvp_providers.dart';
export 'session_providers.dart';
export 'user_providers.dart';
