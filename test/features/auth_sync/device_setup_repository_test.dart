import 'package:al_asad_traders/features/auth_sync/data/device_setup_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DeviceSetupRepository (S33)', () {
    late FakeFirebaseFirestore firestore;
    late SharedPreferences prefs;
    late DeviceSetupRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      firestore = FakeFirebaseFirestore();
      repository = DeviceSetupRepository(firestore, prefs: prefs);
    });

    test('isDeviceSetupCompleted returns false initially', () async {
      expect(await repository.isDeviceSetupCompleted(), isFalse);
    });

    test('claimDeviceLetter claims letter A when registry is empty', () async {
      final String letter = await repository.claimDeviceLetter();
      expect(letter, 'A');
      expect(prefs.getString('device_letter'), 'A');
      expect(prefs.getInt('device_last_number'), 0);

      final doc = await firestore
          .collection('deviceRegistry')
          .doc('main')
          .get();
      expect(doc.data()?['nextIndex'], 1);

      final deviceDoc = await firestore.collection('devices').doc('A').get();
      expect(deviceDoc.exists, isTrue);
      expect(deviceDoc.data()?['lastNumber'], 0);
    });

    test(
      'claimDeviceLetter increments nextIndex correctly when registry exists',
      () async {
        await firestore.collection('deviceRegistry').doc('main').set(
          <String, dynamic>{'nextIndex': 26},
        );

        final String letter = await repository.claimDeviceLetter();
        expect(letter, 'AA');

        final doc = await firestore
            .collection('deviceRegistry')
            .doc('main')
            .get();
        expect(doc.data()?['nextIndex'], 27);

        final deviceDoc = await firestore.collection('devices').doc('AA').get();
        expect(deviceDoc.exists, isTrue);
      },
    );

    test(
      'performFullSync reads all collections and marks setup completed',
      () async {
        await repository.performFullSync();
        expect(await repository.isDeviceSetupCompleted(), isTrue);
      },
    );
  });
}
