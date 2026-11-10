import 'dart:async';

import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/sync_chip.dart';
import 'package:al_asad_traders/features/auth_sync/data/sync_tracker.dart';
import 'package:al_asad_traders/features/auth_sync/providers/sync_provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncChip widget integration with SyncStateProvider', () {
    testWidgets('SyncChip updates when sync state changes', (tester) async {
      final Completer<void> completer = Completer<void>();
      final tracker = SyncTracker(
        firestore: FakeFirebaseFirestore(),
        waitForPendingWritesFn: () => completer.future,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [syncTrackerProvider.overrideWithValue(tracker)],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final bool isSynced = ref.watch(syncStateProvider);
                  return SyncChip(isSynced: isSynced);
                },
              ),
            ),
          ),
        ),
      );

      // Initially not synced
      expect(find.text(AppStrings.notSyncedYet), findsOneWidget);

      // Complete sync
      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.synced), findsOneWidget);
      tracker.dispose();
    });
  });
}
