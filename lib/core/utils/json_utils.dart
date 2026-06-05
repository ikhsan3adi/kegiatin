class JsonUtils {
  static String stringFromJson(Object? json) {
    if (json == null) return '';
    return json.toString();
  }

  static DateTime dateTimeFromJson(Object? json) {
    if (json == null) return DateTime.now();
    if (json is String) {
      final parsed = DateTime.parse(json);
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    return DateTime.now();
  }

  static String dateTimeToJson(DateTime dt) {
    return dt.toUtc().toIso8601String();
  }

  static DateTime? nullableDateTimeFromJson(Object? json) {
    if (json == null) return null;
    if (json is String) {
      final parsed = DateTime.parse(json);
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    return null;
  }

  static String? nullableDateTimeToJson(DateTime? dt) {
    if (dt == null) return null;
    return dt.toUtc().toIso8601String();
  }
}
