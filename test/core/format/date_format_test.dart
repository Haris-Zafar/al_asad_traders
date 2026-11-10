import 'package:al_asad_traders/core/format/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDateFormat', () {
    final date = DateTime(2026, 11, 12, 14, 30);

    test('formatShort outputs day and abbreviated month', () {
      expect(AppDateFormat.formatShort(date), '12 Nov');
    });

    test('format outputs day, abbreviated month and year', () {
      expect(AppDateFormat.format(date), '12 Nov 2026');
    });

    test('formatWithTime outputs date and 12-hour timestamp', () {
      expect(AppDateFormat.formatWithTime(date), '12 Nov 2026, 02:30 PM');
    });
  });
}
