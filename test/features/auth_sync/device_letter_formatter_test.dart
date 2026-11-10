import 'package:al_asad_traders/features/auth_sync/logic/device_letter_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceLetterFormatter (S33)', () {
    test('converts indices to spreadsheet column letters correctly', () {
      expect(indexToLetter(0), 'A');
      expect(indexToLetter(25), 'Z');
      expect(indexToLetter(26), 'AA');
      expect(indexToLetter(27), 'AB');
      expect(indexToLetter(51), 'AZ');
      expect(indexToLetter(52), 'BA');
      expect(indexToLetter(701), 'ZZ');
      expect(indexToLetter(702), 'AAA');
    });

    test('throws ArgumentError for negative indices', () {
      expect(() => indexToLetter(-1), throwsArgumentError);
    });
  });
}
