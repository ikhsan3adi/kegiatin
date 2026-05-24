class JsonUtils {
  static String stringFromJson(Object? json) {
    if (json == null) return '';
    return json.toString();
  }
}
