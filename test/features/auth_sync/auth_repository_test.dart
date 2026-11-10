import 'package:al_asad_traders/features/auth_sync/data/auth_repository.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository', () {
    late MockFirebaseAuth mockAuth;
    late AuthRepository repository;

    setUp(() {
      final MockUser mockUser = MockUser(
        uid: 'test-owner-uid',
        email: 'owner@alasad.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: false);
      repository = AuthRepository(mockAuth);
    });

    test('authStateChanges emits current user state', () async {
      expect(repository.currentUser, isNull);

      final streamExpectation = expectLater(
        repository.authStateChanges(),
        emitsInOrder([isNull, isNotNull]),
      );

      await repository.signInWithEmailAndPassword(
        email: 'owner@alasad.com',
        password: 'password123',
      );

      await streamExpectation;
      expect(repository.currentUser?.email, 'owner@alasad.com');
    });

    test(
      'signInWithEmailAndPassword authenticates valid credentials',
      () async {
        final credential = await repository.signInWithEmailAndPassword(
          email: 'owner@alasad.com',
          password: 'password123',
        );

        expect(credential.user?.email, 'owner@alasad.com');
        expect(repository.currentUser, isNotNull);
      },
    );

    test('signOut clears authenticated user session', () async {
      await repository.signInWithEmailAndPassword(
        email: 'owner@alasad.com',
        password: 'password123',
      );
      expect(repository.currentUser, isNotNull);

      await repository.signOut();
      expect(repository.currentUser, isNull);
    });
  });
}
