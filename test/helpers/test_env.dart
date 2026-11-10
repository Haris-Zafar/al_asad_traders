import 'package:al_asad_traders/core/theme/text_scale.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_scanner.dart';
import 'fixed_clock.dart';

/// Test environment harness providing fake Firestore, signed-in mock auth,
/// mocked SharedPreferences, fixed clock, fake scanner, and Riverpod container.
/// Rule: docs/TESTING.md > Helpers. Story: none.
class TestEnv {
  /// Internal constructor with pre-configured dependencies.
  TestEnv._({
    required this.firestore,
    required this.auth,
    required this.clock,
    required this.scanner,
    required this.container,
  });

  /// Fake in-memory Firestore instance.
  final FakeFirebaseFirestore firestore;

  /// Mock Firebase Auth instance with a default signed-in user.
  final MockFirebaseAuth auth;

  /// Predictable clock for controlling time-dependent logic.
  final FixedClock clock;

  /// Fake scanner for controlling hardware barcode scanning tests.
  final FakeScanner scanner;

  /// Riverpod [ProviderContainer] scoped for test assertions.
  final ProviderContainer container;

  /// Creates and initializes a [TestEnv] with mock services and signed-in user.
  static Future<TestEnv> create({
    Map<String, Object>? sharedPreferencesValues,
    bool signedIn = true,
    String uid = 'test-owner-uid',
    String email = 'owner@alasad.com',
    DateTime? initialTime,
    List<dynamic> overrides = const [],
  }) async {
    final Map<String, Object> prefs = {
      TextScaleChoice.prefKey: 'normal',
      ...?sharedPreferencesValues,
    };
    SharedPreferences.setMockInitialValues(prefs);

    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockUser mockUser = MockUser(
      uid: uid,
      email: email,
      displayName: 'Owner',
      isAnonymous: false,
    );
    final MockFirebaseAuth auth = MockFirebaseAuth(
      mockUser: mockUser,
      signedIn: signedIn,
    );
    final FixedClock clock = FixedClock(initialTime);
    final FakeScanner scanner = FakeScanner();

    final ProviderContainer container = ProviderContainer(
      overrides: overrides.cast(),
    );

    return TestEnv._(
      firestore: firestore,
      auth: auth,
      clock: clock,
      scanner: scanner,
      container: container,
    );
  }

  /// Disposes resources held by the test container.
  void dispose() {
    container.dispose();
  }
}
