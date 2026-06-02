import 'package:flutter_test/flutter_test.dart';
import 'package:kegiatin/core/utils/json_utils.dart';

void main() {
  group('stringFromJson', () {
    test('returns empty string for null', () {
      expect(JsonUtils.stringFromJson(null), '');
    });

    test('returns string value', () {
      expect(JsonUtils.stringFromJson('hello'), 'hello');
    });
  });

  group('dateTimeFromJson', () {
    test('parses ISO string to local DateTime', () {
      final result = JsonUtils.dateTimeFromJson('2026-01-15T10:00:00.000Z');
      expect(result.year, 2026);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('returns DateTime.now() for null', () {
      final result = JsonUtils.dateTimeFromJson(null);
      expect(result, isA<DateTime>());
    });
  });

  group('dateTimeToJson', () {
    test('returns UTC ISO 8601 string', () {
      final dt = DateTime.utc(2026, 1, 15, 10, 0, 0);
      expect(JsonUtils.dateTimeToJson(dt), '2026-01-15T10:00:00.000Z');
    });
  });

  group('nullableDateTimeFromJson', () {
    test('returns null for null', () {
      expect(JsonUtils.nullableDateTimeFromJson(null), isNull);
    });

    test('parses valid ISO string', () {
      final result = JsonUtils.nullableDateTimeFromJson('2026-01-15T10:00:00.000Z');
      expect(result, isNotNull);
      expect(result!.year, 2026);
    });
  });

  group('nullableDateTimeToJson', () {
    test('returns null for null input', () {
      expect(JsonUtils.nullableDateTimeToJson(null), isNull);
    });

    test('returns UTC ISO string for valid DateTime', () {
      final dt = DateTime.utc(2026, 6, 15, 14, 30, 0);
      expect(JsonUtils.nullableDateTimeToJson(dt), '2026-06-15T14:30:00.000Z');
    });
  });
}
