import 'package:al_asad_traders/core/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('MoneyText widget tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets('renders positive and negative amounts at scale $scale', (
        tester,
      ) async {
        await tester.pumpApp(
          const Column(
            children: [
              MoneyText(amount: 125000),
              MoneyText(amount: -4500),
              MoneyText(amount: 0),
              MoneyText(amount: 850, includeCurrency: false),
            ],
          ),
          textScale: scale,
        );

        expect(find.text('Rs 125,000'), findsOneWidget);
        expect(find.text('-Rs 4,500'), findsOneWidget);
        expect(find.text('Rs 0'), findsOneWidget);
        expect(find.text('850'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
