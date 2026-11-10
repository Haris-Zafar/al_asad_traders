import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/app_dialogs.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/empty_state.dart';
import 'package:al_asad_traders/core/widgets/error_panel.dart';
import 'package:al_asad_traders/core/widgets/loading_view.dart';
import 'package:al_asad_traders/core/widgets/picker_sheet.dart';
import 'package:al_asad_traders/core/widgets/search_field.dart';
import 'package:al_asad_traders/core/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Additional shared widgets tests', () {
    for (final double scale in [1.0, 1.8]) {
      testWidgets(
        'renders SearchField, AppListRow, and SectionHeader at scale $scale',
        (tester) async {
          String query = '';
          await tester.pumpApp(
            SingleChildScrollView(
              child: Column(
                children: [
                  SearchField(
                    hintText: 'Search buyers',
                    onChanged: (text) => query = text,
                  ),
                  SectionHeader(
                    title: 'Pending Demands',
                    actionLabel: 'See All',
                    onAction: () {},
                  ),
                  AppListRow(
                    title: 'Malik Fruits & Vegetables Wholesale Store',
                    subtitle: 'Demand open - 5 items',
                    trailing: const Text('Rs 12,000'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            textScale: scale,
          );

          expect(find.text('Search buyers'), findsOneWidget);
          expect(find.text('Pending Demands'), findsOneWidget);
          expect(find.text('See All'), findsOneWidget);
          expect(
            find.text('Malik Fruits & Vegetables Wholesale Store'),
            findsOneWidget,
          );
          expect(find.text('Rs 12,000'), findsOneWidget);

          await tester.enterText(find.byType(SearchField), 'Malik');
          await tester.pumpAndSettle();
          expect(query, equals('Malik'));
          expect(find.byIcon(Icons.clear), findsOneWidget);

          await tester.tap(find.byIcon(Icons.clear));
          await tester.pumpAndSettle();
          expect(query, isEmpty);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('renders EmptyState and ErrorPanel at scale $scale', (
        tester,
      ) async {
        bool retryTriggered = false;
        await tester.pumpApp(
          SingleChildScrollView(
            child: Column(
              children: [
                EmptyState(
                  icon: Icons.receipt_long,
                  message: 'No bills yet',
                  buttonLabel: AppStrings.newBill,
                  onButtonPressed: () {},
                ),
                ErrorPanel(
                  message: AppStrings.errorCouldNotLoad,
                  onRetry: () => retryTriggered = true,
                ),
              ],
            ),
          ),
          textScale: scale,
        );

        expect(find.text('No bills yet'), findsOneWidget);
        expect(find.text(AppStrings.newBill), findsOneWidget);
        expect(find.text(AppStrings.errorCouldNotLoad), findsOneWidget);
        expect(find.text(AppStrings.tryAgain), findsOneWidget);

        await tester.tap(find.text(AppStrings.tryAgain));
        await tester.pumpAndSettle();
        expect(retryTriggered, isTrue);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders LoadingView at scale $scale', (tester) async {
        await tester.pumpApp(
          const LoadingView(message: 'Downloading your data, 5 of 19'),
          textScale: scale,
          settle: false,
        );

        expect(find.text('Downloading your data, 5 of 19'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('PickerSheet filters and selects item', (tester) async {
      String? selectedBuyer;
      final List<String> buyers = [
        'Al-Madina Store',
        'Bismillah Traders',
        'Chaudhry Super',
      ];

      await tester.pumpApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                selectedBuyer = await PickerSheet.show<String>(
                  context,
                  title: 'Select Buyer',
                  searchHint: 'Search buyers',
                  items: buyers,
                  itemTitle: (item) => item,
                );
              },
              child: const Text('Open Picker'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Select Buyer'), findsOneWidget);
      expect(find.text('Al-Madina Store'), findsOneWidget);
      expect(find.text('Bismillah Traders'), findsOneWidget);

      await tester.enterText(find.byType(SearchField), 'Bismillah');
      await tester.pumpAndSettle();

      expect(find.text('Bismillah Traders'), findsOneWidget);
      expect(find.text('Al-Madina Store'), findsNothing);

      await tester.tap(find.text('Bismillah Traders'));
      await tester.pumpAndSettle();

      expect(selectedBuyer, equals('Bismillah Traders'));
    });

    testWidgets('showConfirmDialog and showMessageDialog open and respond', (
      tester,
    ) async {
      bool? confirmResult;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                confirmResult = await showConfirmDialog(
                  context,
                  title: 'Finish Bill',
                  message: 'Do you want to finalize this bill?',
                  confirmLabel: AppStrings.yesFinish,
                );
              },
              child: const Text('Open Confirm'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Finish Bill'), findsOneWidget);
      expect(find.text('Do you want to finalize this bill?'), findsOneWidget);
      expect(find.text(AppStrings.yesFinish), findsOneWidget);

      await tester.tap(find.text(AppStrings.yesFinish));
      await tester.pumpAndSettle();

      expect(confirmResult, isTrue);
    });
  });
}
