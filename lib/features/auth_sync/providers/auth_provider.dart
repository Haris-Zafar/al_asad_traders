import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/auth_sync/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider emitting the current Firebase Auth [User].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S32.
final StreamProvider<User?> authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Controller for performing owner login operations.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S32.
class LoginNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Signs in the owner with [email] and [password].
  /// Rule: wholesale_project.md > Login, device and sync. Story: S32.
  Future<void> signIn({required String email, required String password}) async {
    final String trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      state = AsyncValue.error(
        const ValidationException(AppStrings.errorInvalidCredentials),
        StackTrace.current,
      );
      return;
    }
    if (password.isEmpty) {
      state = AsyncValue.error(
        const ValidationException(AppStrings.errorInvalidCredentials),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final AuthRepository repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
    });
  }
}

/// Provider for [LoginNotifier].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S32.
final NotifierProvider<LoginNotifier, AsyncValue<void>>
loginControllerProvider = NotifierProvider<LoginNotifier, AsyncValue<void>>(
  LoginNotifier.new,
);
