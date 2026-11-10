import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppButton widget tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets('renders primary button without overflow at scale $scale', (
        tester,
      ) async {
        bool pressed = false;
        await tester.pumpApp(
          AppButton(
            label: 'Submit Order',
            icon: Icons.check,
            onPressed: () => pressed = true,
          ),
          textScale: scale,
        );

        expect(find.text('Submit Order'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);

        final Size buttonSize = tester.getSize(find.byType(AppButton));
        expect(buttonSize.height, greaterThanOrEqualTo(AppSizes.buttonHeight));

        await tester.tap(find.byType(AppButton));
        expect(pressed, isTrue);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders secondary and danger variants at scale $scale', (
        tester,
      ) async {
        await tester.pumpApp(
          Column(
            children: [
              AppButton(
                label: 'Cancel Action',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
              AppButton(
                label: 'Delete Invoice',
                variant: AppButtonVariant.danger,
                onPressed: () {},
              ),
            ],
          ),
          textScale: scale,
        );

        expect(find.text('Cancel Action'), findsOneWidget);
        expect(find.text('Delete Invoice'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders loading state at scale $scale', (tester) async {
        await tester.pumpApp(
          AppButton(label: 'Processing', isLoading: true, onPressed: () {}),
          textScale: scale,
          settle: false,
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
