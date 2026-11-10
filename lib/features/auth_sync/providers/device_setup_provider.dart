import 'package:al_asad_traders/features/auth_sync/data/device_setup_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier tracking whether device setup has been completed.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S33.
class DeviceSetupStatusNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  /// Sets the device setup completion state.
  void setCompleted(bool completed) {
    state = completed;
  }
}

/// Provider for [DeviceSetupStatusNotifier].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S33.
final NotifierProvider<DeviceSetupStatusNotifier, bool>
deviceSetupCompletedProvider =
    NotifierProvider<DeviceSetupStatusNotifier, bool>(
      DeviceSetupStatusNotifier.new,
    );

/// Controller performing the first-time device setup operation.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S33.
class DeviceSetupNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Executes first login device setup transaction and full sync.
  /// Rule: wholesale_project.md > S33. Story: S33.
  Future<void> runSetup() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final DeviceSetupRepository repo = ref.read(
        deviceSetupRepositoryProvider,
      );
      await repo.executeFirstSetup();
      ref.read(deviceSetupCompletedProvider.notifier).setCompleted(true);
    });
  }
}

/// Provider for [DeviceSetupNotifier].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S33.
final NotifierProvider<DeviceSetupNotifier, AsyncValue<void>>
deviceSetupControllerProvider =
    NotifierProvider<DeviceSetupNotifier, AsyncValue<void>>(
      DeviceSetupNotifier.new,
    );
