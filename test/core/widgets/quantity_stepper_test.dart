import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('QuantityStepper widget tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets(
        'renders stepper and triggers increment/decrement at scale $scale',
        (tester) async {
          int quantity = 5;
          await tester.pumpApp(
            StatefulBuilder(
              builder: (context, setState) {
                return QuantityStepper(
                  quantity: quantity,
                  onChanged: (val) => setState(() => quantity = val),
                );
              },
            ),
            textScale: scale,
          );

          expect(find.text('5'), findsOneWidget);
          expect(find.byTooltip(AppStrings.decrease), findsOneWidget);
          expect(find.byTooltip(AppStrings.increase), findsOneWidget);

          await tester.tap(find.byTooltip(AppStrings.increase));
          await tester.pumpAndSettle();
          expect(quantity, equals(6));
          expect(find.text('6'), findsOneWidget);

          await tester.tap(find.byTooltip(AppStrings.decrease));
          await tester.pumpAndSettle();
          expect(quantity, equals(5));
          expect(find.text('5'), findsOneWidget);

          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('tapping quantity displays edit dialog', (tester) async {
      int quantity = 10;
      await tester.pumpApp(
        QuantityStepper(quantity: quantity, onChanged: (val) => quantity = val),
      );

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(AppStrings.ok), findsOneWidget);
      expect(find.text(AppStrings.cancel), findsOneWidget);

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
