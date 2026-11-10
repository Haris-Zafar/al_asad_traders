import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/auth_sync/data/auth_repository.dart';
import 'package:al_asad_traders/features/auth_sync/providers/auth_provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthProvider and LoginNotifier', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      final MockUser mockUser = MockUser(
        uid: 'test-owner-uid',
        email: 'owner@alasad.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: false);
    });

    test(
      'authStateProvider emits null when signed out and user when signed in',
      () async {
        final container = ProviderContainer(
          overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        );
        addTearDown(container.dispose);

        // Keep subscription active
        container.listen(authStateProvider, (_, _) {});

        expect(container.read(authStateProvider).value, isNull);

        await container
            .read(authRepositoryProvider)
            .signInWithEmailAndPassword(
              email: 'owner@alasad.com',
              password: 'password123',
            );

        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(authStateProvider).value?.email,
          'owner@alasad.com',
        );
      },
    );

    test('LoginNotifier rejects empty or invalid email', () async {
      final container = ProviderContainer(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginControllerProvider.notifier);
      await notifier.signIn(email: 'invalid-email', password: 'password123');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<ValidationException>());
    });

    test('LoginNotifier rejects empty password', () async {
      final container = ProviderContainer(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginControllerProvider.notifier);
      await notifier.signIn(email: 'owner@alasad.com', password: '');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<ValidationException>());
    });

    test(
      'LoginNotifier signs in successfully with valid credentials',
      () async {
        final container = ProviderContainer(
          overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(loginControllerProvider.notifier);
        await notifier.signIn(
          email: 'owner@alasad.com',
          password: 'password123',
        );

        final state = container.read(loginControllerProvider);
        expect(state.hasError, isFalse);
        expect(mockAuth.currentUser, isNotNull);
      },
    );
  });
}
