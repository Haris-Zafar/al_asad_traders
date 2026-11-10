import 'package:al_asad_traders/features/auth_sync/data/sync_tracker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [SyncTracker].
/// Rule: docs/DATABASE.md > Sync. Story: S34.
final Provider<SyncTracker> syncTrackerProvider = Provider<SyncTracker>((ref) {
  final tracker = SyncTracker();
  ref.onDispose(tracker.dispose);
  return tracker;
});

/// Provider reflecting whether all Firestore writes are synced (`isSynced`).
/// Rule: docs/DATABASE.md > Sync. Story: S34.
final NotifierProvider<SyncStateNotifier, bool> syncStateProvider =
    NotifierProvider<SyncStateNotifier, bool>(SyncStateNotifier.new);

/// Notifier managing sync state from [SyncTracker].
class SyncStateNotifier extends Notifier<bool> {
  @override
  bool build() {
    final tracker = ref.watch(syncTrackerProvider);
    tracker.isSyncedListenable.addListener(_onSyncChanged);
    ref.onDispose(() {
      tracker.isSyncedListenable.removeListener(_onSyncChanged);
    });
    return tracker.isSynced;
  }

  void _onSyncChanged() {
    state = ref.read(syncTrackerProvider).isSynced;
  }
}
