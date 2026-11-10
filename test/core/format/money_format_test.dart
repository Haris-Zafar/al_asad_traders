import 'package:al_asad_traders/core/format/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormat', () {
    test('formats whole numbers with thousands separators', () {
      expect(MoneyFormat.format(0), '0');
      expect(MoneyFormat.format(5), '5');
      expect(MoneyFormat.format(150), '150');
      expect(MoneyFormat.format(1200), '1,200');
      expect(MoneyFormat.format(5100), '5,100');
      expect(MoneyFormat.format(100000), '100,000');
      expect(MoneyFormat.format(5000000), '5,000,000');
    });

    test('formats negative amounts with thousands separators', () {
      expect(MoneyFormat.format(-150), '-150');
      expect(MoneyFormat.format(-1200), '-1,200');
      expect(MoneyFormat.format(-5000000), '-5,000,000');
    });

    test('formats amounts with currency label', () {
      expect(MoneyFormat.formatWithCurrency(0), 'Rs 0');
      expect(MoneyFormat.formatWithCurrency(1500), 'Rs 1,500');
      expect(MoneyFormat.formatWithCurrency(5100), 'Rs 5,100');
      expect(MoneyFormat.formatWithCurrency(-1500), '-Rs 1,500');
    });

    test('parses plain and formatted numbers correctly', () {
      expect(MoneyFormat.parse('0'), 0);
      expect(MoneyFormat.parse('1500'), 1500);
      expect(MoneyFormat.parse('1,500'), 1500);
      expect(MoneyFormat.parse('  5,000,000  '), 5000000);
      expect(MoneyFormat.parse('-1,200'), -1200);
    });

    test('returns null for non-integer inputs', () {
      expect(MoneyFormat.parse(''), isNull);
      expect(MoneyFormat.parse('abc'), isNull);
      expect(MoneyFormat.parse('12.50'), isNull);
      expect(MoneyFormat.parse('Rs 1500'), isNull);
    });
  });
}
