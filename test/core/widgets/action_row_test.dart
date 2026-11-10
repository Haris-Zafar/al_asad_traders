import 'package:al_asad_traders/core/widgets/action_row.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ActionRow widget tests', () {
    testWidgets('arranges buttons in Row at scale 1.0', (tester) async {
      await tester.pumpApp(
        ActionRow(
          primary: AppButton(label: 'Save', onPressed: () {}),
          secondary: AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
        textScale: 1.0,
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'stacks buttons vertically in Column at scale 1.8 without overflow',
      (tester) async {
        await tester.pumpApp(
          ActionRow(
            primary: AppButton(label: 'Save Changes Now', onPressed: () {}),
            secondary: AppButton(
              label: 'Discard Action',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
          ),
          textScale: 1.8,
        );

        expect(find.text('Save Changes Now'), findsOneWidget);
        expect(find.text('Discard Action'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
