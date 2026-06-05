import 'package:flutter_test/flutter_test.dart';
import 'package:kegiatin/core/utils/date_formatter.dart';

void main() {
  group('formatDateShort', () {
    test('formats 1 Jan 2026', () {
      final dt = DateTime(2026, 1, 1, 10, 0, 0);
      expect(DateFormatter.formatDateShort(dt), '1 Jan 2026');
    });

    test('formats 15 Mei 2026', () {
      final dt = DateTime(2026, 5, 15, 10, 0, 0);
      expect(DateFormatter.formatDateShort(dt), '15 Mei 2026');
    });

    test('formats 31 Des 2026', () {
      final dt = DateTime(2026, 12, 31, 10, 0, 0);
      expect(DateFormatter.formatDateShort(dt), '31 Des 2026');
    });

    test('covers all 12 abbreviated month names', () {
      final months = <String>[];
      for (var m = 1; m <= 12; m++) {
        final dt = DateTime(2026, m, 1);
        final formatted = DateFormatter.formatDateShort(dt);
        months.add(formatted.split(' ')[1]);
      }
      expect(months, [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ]);
    });
  });
}
