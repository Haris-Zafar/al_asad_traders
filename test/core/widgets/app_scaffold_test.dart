import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppScaffold widget tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets('renders body without overflow at scale $scale', (
        tester,
      ) async {
        await tester.pumpApp(
          const AppScaffold(
            title: 'Test Title',
            body: Text('Test Body Content'),
          ),
          textScale: scale,
        );

        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test Body Content'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders sticky footer without overflow at scale $scale', (
        tester,
      ) async {
        await tester.pumpApp(
          AppScaffold(
            title: 'Footer Screen',
            body: const Text('Main Scrollable Body'),
            footer: AppButton(label: 'Save Changes', onPressed: () {}),
          ),
          textScale: scale,
        );

        expect(find.text('Footer Screen'), findsOneWidget);
        expect(find.text('Main Scrollable Body'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
