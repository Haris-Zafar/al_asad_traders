import 'package:al_asad_traders/app/app.dart';
import 'package:al_asad_traders/app/router.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/auth_sync/data/auth_repository.dart';
import 'package:al_asad_traders/features/auth_sync/providers/device_setup_provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSetupNotifier extends DeviceSetupStatusNotifier {
  _FakeSetupNotifier(this._value);
  final bool _value;

  @override
  bool build() => _value;
}

void main() {
  group('Router and AppShell navigation', () {
    late MockFirebaseAuth mockSignedInAuth;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'device_setup_completed': true,
      });
      final MockUser mockUser = MockUser(
        uid: 'test-owner-uid',
        email: 'owner@alasad.com',
      );
      mockSignedInAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    });

    testWidgets('redirects to /login when unauthenticated', (
      WidgetTester tester,
    ) async {
      final MockFirebaseAuth signedOutAuth = MockFirebaseAuth(signedIn: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [firebaseAuthProvider.overrideWithValue(signedOutAuth)],
          child: const AlAsadApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    });

    testWidgets('redirects to /setup when signed in and setup not completed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockSignedInAuth),
            deviceSetupCompletedProvider.overrideWith(
              () => _FakeSetupNotifier(false),
            ),
          ],
          child: const AlAsadApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Device setup'), findsOneWidget);
    });

    testWidgets(
      'launches into 4-tab shell with Bills as initial tab when signed in',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              firebaseAuthProvider.overrideWithValue(mockSignedInAuth),
            ],
            child: const AlAsadApp(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('bills_tab_screen')), findsOneWidget);
        expect(find.text(AppStrings.billsTab), findsWidgets);
        expect(find.text(AppStrings.demandsTab), findsWidgets);
        expect(find.text(AppStrings.buyersTab), findsWidgets);
        expect(find.text(AppStrings.moreTab), findsWidgets);
      },
    );

    testWidgets(
      'switches tabs when bottom navigation destinations are tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              firebaseAuthProvider.overrideWithValue(mockSignedInAuth),
            ],
            child: const AlAsadApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Demands tab
        await tester.tap(find.byKey(const Key('tab_demands')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('demands_tab_screen')), findsOneWidget);

        // Tap Buyers tab
        await tester.tap(find.byKey(const Key('tab_buyers')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('buyers_screen')), findsOneWidget);

        // Tap More tab
        await tester.tap(find.byKey(const Key('tab_more')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('more_tab_screen')), findsOneWidget);

        // Tap Bills tab
        await tester.tap(find.byKey(const Key('tab_bills')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('bills_tab_screen')), findsOneWidget);
      },
    );

    testWidgets('preserves backstack state per tab when switching tabs', (
      WidgetTester tester,
    ) async {
      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockSignedInAuth),
            routerProvider.overrideWith((ref) {
              router = createRouter();
              return router;
            }),
          ],
          child: const AlAsadApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to demands tab and push nested details route
      await tester.tap(find.byKey(const Key('tab_demands')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('demands_tab_screen')), findsOneWidget);

      router.go('/demands/details');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('demand_details_screen')), findsOneWidget);

      // Switch to Bills tab
      await tester.tap(find.byKey(const Key('tab_bills')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bills_tab_screen')), findsOneWidget);

      // Switch back to Demands tab - nested details route should still be preserved
      await tester.tap(find.byKey(const Key('tab_demands')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('demand_details_screen')), findsOneWidget);
    });

    testWidgets(
      'Android back button on non-Bills tab root returns to Bills tab',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              firebaseAuthProvider.overrideWithValue(mockSignedInAuth),
            ],
            child: const AlAsadApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Go to Demands tab root
        await tester.tap(find.byKey(const Key('tab_demands')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('demands_tab_screen')), findsOneWidget);

        // Simulate Android back button
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Should return to Bills tab
        expect(find.byKey(const Key('bills_tab_screen')), findsOneWidget);
      },
    );

    testWidgets(
      'Android back button on nested branch route pops to branch root first',
      (WidgetTester tester) async {
        late GoRouter router;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              firebaseAuthProvider.overrideWithValue(mockSignedInAuth),
              routerProvider.overrideWith((ref) {
                router = createRouter();
                return router;
              }),
            ],
            child: const AlAsadApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to Demands tab and push details
        await tester.tap(find.byKey(const Key('tab_demands')));
        await tester.pumpAndSettle();
        router.go('/demands/details');
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('demand_details_screen')), findsOneWidget);

        // First back press: pops details screen to demands tab root
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('demands_tab_screen')), findsOneWidget);

        // Second back press: returns from demands tab root to bills tab root
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('bills_tab_screen')), findsOneWidget);
      },
    );

    testWidgets('Android back button on Bills tab root allows pop / exit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [firebaseAuthProvider.overrideWithValue(mockSignedInAuth)],
          child: const AlAsadApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bills_tab_screen')), findsOneWidget);

      // Handle pop route on root should return true (or popped result) indicating handled/poppable
      final bool handled = await tester.binding.handlePopRoute();
      expect(handled, isFalse);
    });
  });
}
