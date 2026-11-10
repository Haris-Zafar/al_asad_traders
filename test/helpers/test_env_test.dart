import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('TestEnv and helpers unit tests', () {
    test('FixedClock advances deterministically', () {
      final initial = DateTime(2026, 11, 10, 8, 30);
      final clock = FixedClock(initial);

      expect(clock.now(), equals(initial));

      clock.advance(const Duration(minutes: 45));
      expect(clock.now(), equals(DateTime(2026, 11, 10, 9, 15)));

      clock.set(DateTime(2026, 11, 12, 12));
      expect(clock.now(), equals(DateTime(2026, 11, 12, 12)));
    });

    test('FakeScanner manages barcode queue', () {
      final scanner = FakeScanner();
      expect(scanner.scanNext(), isNull);

      scanner.queueBarcode('123456');
      scanner.queueBarcode('789012');

      expect(scanner.scanNext(), equals('123456'));
      expect(scanner.scanNext(), equals('789012'));
      expect(scanner.scanNext(), isNull);
    });

    test('TestEnv initializes mock Firebase, auth and container', () async {
      final env = await TestEnv.create(
        uid: 'owner-123',
        email: 'owner@test.com',
      );
      addTearDown(env.dispose);

      expect(env.auth.currentUser, isNotNull);
      expect(env.auth.currentUser!.uid, equals('owner-123'));
      expect(env.auth.currentUser!.email, equals('owner@test.com'));
      expect(env.firestore, isNotNull);
      expect(env.container, isNotNull);
      expect(env.clock, isNotNull);
      expect(env.scanner, isNotNull);
    });
  });
}
