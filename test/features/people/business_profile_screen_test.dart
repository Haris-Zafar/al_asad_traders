import 'package:al_asad_traders/features/people/data/profile_repository.dart';
import 'package:al_asad_traders/features/people/models/profile.dart';
import 'package:al_asad_traders/features/people/ui/business_profile_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('BusinessProfileScreen (S11)', () {
    testWidgets('renders business profile form and saves successfully', (
      WidgetTester tester,
    ) async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final ProfileRepository repo = ProfileRepository(firestore);

      await repo.saveProfile(
        const Profile(
          id: 'main',
          businessName: 'Initial Name',
          businessAddress: 'Initial Address',
          contactNumber1: '11111111',
          contactNumber2: '22222222',
        ),
      );

      final ProviderContainer container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );

      await tester.pumpApp(const BusinessProfileScreen(), container: container);

      expect(find.byKey(const Key('business_name_field')), findsOneWidget);
      expect(find.byKey(const Key('business_address_field')), findsOneWidget);
      expect(find.byKey(const Key('contact_number_1_field')), findsOneWidget);
      expect(find.byKey(const Key('contact_number_2_field')), findsOneWidget);
      expect(find.byKey(const Key('save_profile_button')), findsOneWidget);

      // Enter new name and save
      await tester.enterText(
        find.byKey(const Key('business_name_field')),
        'Updated Business',
      );
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Verify saved in firestore
      final Profile? updated = await repo.getProfile();
      expect(updated?.businessName, 'Updated Business');
      expect(find.text('Business profile saved successfully'), findsOneWidget);
    });
  });
}
