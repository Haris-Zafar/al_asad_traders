import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/sync_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SyncChip widget tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets('renders synced and unsynced states at scale $scale', (
        tester,
      ) async {
        bool tapped = false;
        await tester.pumpApp(
          Column(
            children: [
              const SyncChip(isSynced: true),
              SyncChip(isSynced: false, onTap: () => tapped = true),
            ],
          ),
          textScale: scale,
        );

        expect(find.text(AppStrings.synced), findsOneWidget);
        expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);

        expect(find.text(AppStrings.notSyncedYet), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

        await tester.tap(find.text(AppStrings.notSyncedYet));
        expect(tapped, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
