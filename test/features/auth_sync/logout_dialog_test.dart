import 'dart:async';

import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/auth_sync/data/auth_repository.dart';
import 'package:al_asad_traders/features/auth_sync/data/sync_tracker.dart';
import 'package:al_asad_traders/features/auth_sync/providers/sync_provider.dart';
import 'package:al_asad_traders/features/auth_sync/ui/logout_dialog.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('LogoutDialog', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      final MockUser mockUser = MockUser(
        uid: 'test-owner-uid',
        email: 'owner@alasad.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets(
      'shows unsynced warning when not synced yet and logs out on confirm',
      (WidgetTester tester) async {
        final Completer<void> completer = Completer<void>();
        final tracker = SyncTracker(
          firestore: fakeFirestore,
          waitForPendingWritesFn: () => completer.future,
        );

        final container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            syncTrackerProvider.overrideWithValue(tracker),
          ],
        );

        await tester.pumpApp(
          Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                key: const Key('trigger_logout'),
                onPressed: () => showLogoutDialog(context, ref),
                child: const Text('Logout'),
              );
            },
          ),
          container: container,
        );

        // Initially pending (not synced yet)
        await tester.tap(find.byKey(const Key('trigger_logout')));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Some changes are not synced yet. If you log out now, they are lost.',
          ),
          findsOneWidget,
        );
        expect(find.text(AppStrings.wait), findsOneWidget);
        expect(find.text(AppStrings.logOutAnyway), findsOneWidget);

        // Tap Log out anyway
        await tester.tap(find.text(AppStrings.logOutAnyway));
        await tester.pumpAndSettle();

        expect(mockAuth.currentUser, isNull);
        tracker.dispose();
      },
    );

    testWidgets('shows standard logout dialog when synced', (
      WidgetTester tester,
    ) async {
      final tracker = SyncTracker(
        firestore: fakeFirestore,
        waitForPendingWritesFn: () async {},
      );
      await tracker.checkPendingWrites();

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          syncTrackerProvider.overrideWithValue(tracker),
        ],
      );

      await tester.pumpApp(
        Consumer(
          builder: (context, ref, _) {
            return ElevatedButton(
              key: const Key('trigger_logout'),
              onPressed: () => showLogoutDialog(context, ref),
              child: const Text('Logout'),
            );
          },
        ),
        container: container,
      );

      await tester.tap(find.byKey(const Key('trigger_logout')));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      expect(find.text(AppStrings.cancel), findsOneWidget);
      expect(find.text(AppStrings.logOut), findsWidgets);

      // Tap Cancel
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser, isNotNull);
      tracker.dispose();
    });
  });
}
