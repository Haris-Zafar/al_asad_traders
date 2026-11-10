import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StatusChip widget tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets('renders all status variations at scale $scale', (
        tester,
      ) async {
        await tester.pumpApp(
          const Column(
            children: [
              StatusChip(status: AppStatus.draft),
              StatusChip(status: AppStatus.finished),
              StatusChip(status: AppStatus.paid),
              StatusChip(status: AppStatus.onAccount),
            ],
          ),
          textScale: scale,
        );

        expect(find.text(AppStrings.draft), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

        expect(find.text(AppStrings.finished), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

        expect(find.text(AppStrings.paid), findsOneWidget);
        expect(find.byIcon(Icons.done_all), findsOneWidget);

        expect(find.text(AppStrings.onAccount), findsOneWidget);
        expect(
          find.byIcon(Icons.account_balance_wallet_outlined),
          findsOneWidget,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
