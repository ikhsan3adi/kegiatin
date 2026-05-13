/// Mengonversi value JSON yang berpotensi null menjadi string kosong.
///
/// Berguna untuk defensive programming pada data legacy (dari backend)
/// yang masih bernilai null padahal di domain entitas Flutter diwajibkan (non-nullable).
String stringFromJson(Object? json) {
  if (json == null) return '';
  return json.toString();
}
