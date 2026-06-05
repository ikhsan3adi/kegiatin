import 'package:flutter_test/flutter_test.dart';
import 'package:kegiatin/core/utils/string_utils.dart';

void main() {
  group('initials', () {
    test('returns initials from two words', () {
      expect(StringUtils.initials('John Doe'), 'JD');
    });

    test('returns initials from one word', () {
      expect(StringUtils.initials('Alice'), 'A');
    });

    test('returns "?" for empty string', () {
      expect(StringUtils.initials(''), '?');
    });

    test('normalizes multiple whitespace', () {
      expect(StringUtils.initials('  John   Doe  '), 'JD');
    });

    test('handles single character name', () {
      expect(StringUtils.initials('X'), 'X');
    });
  });
}
