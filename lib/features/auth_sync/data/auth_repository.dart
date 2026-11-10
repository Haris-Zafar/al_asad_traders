import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the [FirebaseAuth] instance.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S32.
final Provider<FirebaseAuth> firebaseAuthProvider = Provider<FirebaseAuth>((
  ref,
) {
  return FirebaseAuth.instance;
});

/// Provider for [AuthRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S32.
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
      return AuthRepository(ref.watch(firebaseAuthProvider));
    });

/// Repository handling persistent owner authentication operations.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S32.
class AuthRepository {
  /// Creates an [AuthRepository] with the given [FirebaseAuth] instance.
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// Stream emitting changes to the current authenticated user state.
  /// Rule: docs/ARCHITECTURE.md > Repository. Story: S32.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Gets the currently authenticated user, or `null` if unauthenticated.
  /// Rule: docs/ARCHITECTURE.md > Repository. Story: S32.
  User? get currentUser => _auth.currentUser;

  /// Signs in with [email] and [password].
  ///
  /// Throws [ValidationException] on invalid credentials or malformed inputs,
  /// [PermissionException] if user account is disabled,
  /// [UnavailableException] if offline or network fails,
  /// or [UnknownException] for other authentication errors.
  /// Rule: wholesale_project.md > Login, device and sync. Story: S32.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Signs out the current user.
  /// Rule: wholesale_project.md > Login, device and sync. Story: S35.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  AppException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-email':
      case 'invalid-credential':
        return const ValidationException(AppStrings.errorInvalidCredentials);
      case 'user-disabled':
        return const PermissionException(AppStrings.errorPleaseLogInAgain);
      case 'network-request-failed':
        return const UnavailableException(AppStrings.errorInternetNeeded);
      default:
        return UnknownException(AppStrings.errorGeneric, e);
    }
  }
}
