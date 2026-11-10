import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/people/data/profile_repository.dart';
import 'package:al_asad_traders/features/people/models/profile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileRepository (S11)', () {
    late FakeFirebaseFirestore firestore;
    late ProfileRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ProfileRepository(firestore);
    });

    test('getProfile returns null when profile does not exist', () async {
      final Profile? profile = await repository.getProfile();
      expect(profile, isNull);
    });

    test(
      'saveProfile and getProfile stores and retrieves business profile',
      () async {
        const Profile profile = Profile(
          id: 'main',
          businessName: 'Al Asad Traders',
          businessAddress: 'Main Market',
          contactNumber1: '03001234567',
          contactNumber2: '03219876543',
        );

        await repository.saveProfile(profile);

        final Profile? fetched = await repository.getProfile();
        expect(fetched, isNotNull);
        expect(fetched?.businessName, 'Al Asad Traders');
        expect(fetched?.businessAddress, 'Main Market');
        expect(fetched?.contactNumber1, '03001234567');
        expect(fetched?.contactNumber2, '03219876543');
      },
    );

    test(
      'saveProfile throws ValidationException when business name is empty',
      () async {
        const Profile profile = Profile(
          id: 'main',
          businessName: '',
          businessAddress: 'Main Market',
          contactNumber1: '03001234567',
        );

        expect(
          () => repository.saveProfile(profile),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}
