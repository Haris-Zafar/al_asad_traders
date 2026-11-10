import 'package:al_asad_traders/core/widgets/app_number_field.dart';
import 'package:al_asad_traders/core/widgets/app_text_field.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppTextField and AppNumberField widget tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets('renders AppTextField with label and error at scale $scale', (
        tester,
      ) async {
        await tester.pumpApp(
          const AppTextField(
            label: 'Buyer Name',
            hintText: 'Enter name',
            errorText: 'Name is required',
          ),
          textScale: scale,
        );

        expect(find.text('Buyer Name'), findsOneWidget);
        expect(find.text('Name is required'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders AppNumberField and formats input at scale $scale', (
        tester,
      ) async {
        int? receivedValue;
        await tester.pumpApp(
          AppNumberField(
            label: 'Price per Unit',
            initialValue: 1500,
            onChanged: (val) => receivedValue = val,
          ),
          textScale: scale,
        );

        expect(find.text('Price per Unit'), findsOneWidget);
        expect(find.text('1,500'), findsOneWidget);

        await tester.enterText(find.byType(AppNumberField), '25000');
        await tester.pumpAndSettle();

        expect(find.text('25,000'), findsOneWidget);
        expect(receivedValue, equals(25000));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
