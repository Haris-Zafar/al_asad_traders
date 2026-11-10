import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/people/models/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [ProfileRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S11.
final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((ref) {
      return ProfileRepository(FirebaseFirestore.instance);
    });

/// Repository handling business profile data persistence in Firestore.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S11.
class ProfileRepository {
  /// Creates a [ProfileRepository] with optional [firestore] instance.
  ProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _profileRef =>
      _firestore.collection('profile').doc('main');

  /// Watches the business profile document as a stream.
  /// Rule: docs/ARCHITECTURE.md > State pattern. Story: S11.
  Stream<Profile?> watchProfile() {
    return _profileRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Profile.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  /// Gets the business profile once from local cache/server.
  /// Rule: docs/ARCHITECTURE.md > Repository. Story: S11.
  Future<Profile?> getProfile() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _profileRef
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Profile.fromMap(snapshot.data()!, snapshot.id);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Saves or updates the business profile.
  /// Rule: docs/ARCHITECTURE.md > Writes and offline. Story: S11.
  Future<void> saveProfile(Profile profile) async {
    try {
      if (profile.businessName.trim().isEmpty) {
        throw const ValidationException('Business name cannot be empty');
      }
      await _profileRef.set(profile.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  AppException _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const PermissionException(AppStrings.errorPleaseLogInAgain);
      case 'unavailable':
      case 'network-request-failed':
        return const UnavailableException(AppStrings.errorInternetNeeded);
      default:
        return UnknownException(AppStrings.errorGeneric, e);
    }
  }
}
