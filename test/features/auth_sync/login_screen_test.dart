import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/auth_sync/data/auth_repository.dart';
import 'package:al_asad_traders/features/auth_sync/ui/login_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('LoginScreen', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      final MockUser mockUser = MockUser(
        uid: 'test-owner-uid',
        email: 'owner@alasad.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: false);
    });

    testWidgets(
      'renders login form elements at scale 1.0 and 1.8 without overflow',
      (WidgetTester tester) async {
        for (final double scale in [1.0, 1.8]) {
          final container = ProviderContainer(
            overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
          );

          await tester.pumpApp(
            const LoginScreen(),
            textScale: scale,
            container: container,
          );

          expect(find.text(AppStrings.logIn), findsWidgets);
          expect(find.text(AppStrings.email), findsOneWidget);
          expect(find.text(AppStrings.password), findsOneWidget);
          expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
        }
      },
    );

    testWidgets(
      'displays error message when submitting empty or invalid email',
      (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        );

        await tester.pumpApp(const LoginScreen(), container: container);

        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'bademail',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'secret',
        );
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.errorInvalidCredentials), findsOneWidget);
      },
    );

    testWidgets('authenticates valid owner credentials on submit', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      );

      await tester.pumpApp(const LoginScreen(), container: container);

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'owner@alasad.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser?.email, 'owner@alasad.com');
    });
  });
}
