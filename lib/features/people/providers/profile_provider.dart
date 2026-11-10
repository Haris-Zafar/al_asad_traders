import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/people/data/profile_repository.dart';
import 'package:al_asad_traders/features/people/models/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for the business profile.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S11.
final StreamProvider<Profile?> profileStreamProvider = StreamProvider<Profile?>(
  (ref) {
    return ref.watch(profileRepositoryProvider).watchProfile();
  },
);

/// Controller for saving business profile updates.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S11.
class ProfileController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Saves the business profile with given fields.
  /// Rule: wholesale_project.md > S11. Story: S11.
  Future<void> saveProfile({
    required String businessName,
    required String businessAddress,
    required String contactNumber1,
    String? contactNumber2,
  }) async {
    final String trimmedName = businessName.trim();
    if (trimmedName.isEmpty) {
      state = AsyncValue.error(
        const ValidationException('Business name cannot be empty'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ProfileRepository repo = ref.read(profileRepositoryProvider);
      final Profile profile = Profile(
        id: 'main',
        businessName: trimmedName,
        businessAddress: businessAddress.trim(),
        contactNumber1: contactNumber1.trim(),
        contactNumber2: contactNumber2?.trim().isEmpty == true
            ? null
            : contactNumber2?.trim(),
      );
      await repo.saveProfile(profile);
    });
  }
}

/// Provider for [ProfileController].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S11.
final NotifierProvider<ProfileController, AsyncValue<void>>
profileControllerProvider =
    NotifierProvider<ProfileController, AsyncValue<void>>(
      ProfileController.new,
    );
