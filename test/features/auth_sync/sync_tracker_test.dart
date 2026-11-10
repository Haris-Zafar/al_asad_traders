import 'dart:async';

import 'package:al_asad_traders/features/auth_sync/data/sync_tracker.dart';
import 'package:al_asad_traders/features/auth_sync/providers/sync_provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncTracker and SyncStateProvider tests', () {
    test('SyncTracker starts as not synced and becomes synced when pending writes complete', () async {
      final Completer<void> completer = Completer<void>();
      final tracker = SyncTracker(
        firestore: FakeFirebaseFirestore(),
        waitForPendingWritesFn: () => completer.future,
      );

      // Initially pending / not synced
      expect(tracker.isSynced, isFalse);

      // Complete the pending write
      completer.complete();
      await Future<void>.delayed(Duration.zero);

      expect(tracker.isSynced, isTrue);
      tracker.dispose();
    });

    test(
      'SyncTracker marks pending on new write and resolves when finished',
      () async {
        final Completer<void> completer1 = Completer<void>();
        final tracker = SyncTracker(
          firestore: FakeFirebaseFirestore(),
          waitForPendingWritesFn: () => completer1.future,
        );

        completer1.complete();
        await Future<void>.delayed(Duration.zero);
        expect(tracker.isSynced, isTrue);

        tracker.markPending();
        expect(tracker.isSynced, isFalse);

        tracker.dispose();
      },
    );

    test('syncStateProvider reflects SyncTracker state', () async {
      final Completer<void> completer = Completer<void>();
      final tracker = SyncTracker(
        firestore: FakeFirebaseFirestore(),
        waitForPendingWritesFn: () => completer.future,
      );

      final container = ProviderContainer(
        overrides: [syncTrackerProvider.overrideWithValue(tracker)],
      );
      addTearDown(container.dispose);

      expect(container.read(syncStateProvider), isFalse);

      completer.complete();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(syncStateProvider), isTrue);
      tracker.dispose();
    });
  });
}
