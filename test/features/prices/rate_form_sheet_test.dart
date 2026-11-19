import 'package:al_asad_traders/features/people/providers/buyers_provider.dart';
import 'package:al_asad_traders/features/people/providers/suppliers_provider.dart';
import 'package:al_asad_traders/features/prices/data/rates_repository.dart';
import 'package:al_asad_traders/features/prices/ui/rate_form_sheet.dart';
import 'package:al_asad_traders/features/products/providers/product_provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('RateFormSheet (S5, T-16)', () {
    late FakeFirebaseFirestore firestore;
    late RatesRepository repository;
    late ProviderContainer container;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = RatesRepository(firestore);
      container = ProviderContainer(
        overrides: [
          ratesRepositoryProvider.overrideWithValue(repository),
          buyersStreamProvider.overrideWith((ref) => Stream.value([])),
          suppliersStreamProvider.overrideWith((ref) => Stream.value([])),
          activeProductsProvider.overrideWith(
            (ref) => const AsyncValue.data([]),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('renders RateFormSheet and saves buyer rate', (tester) async {
      await tester.pumpApp(
        const RateFormSheet(buyerId: 'b1', productId: 'p1'),
        container: container,
      );
      await tester.pumpAndSettle();

      expect(find.text('Add rate'), findsOneWidget);
      expect(find.byKey(const Key('rate_amount_field')), findsOneWidget);
      expect(find.byKey(const Key('save_rate_button')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('rate_amount_field')), '250');
      await tester.tap(find.byKey(const Key('save_rate_button')));
      await tester.pumpAndSettle();

      final buyerRates = await repository.watchBuyerRatesForBuyer('b1').first;
      expect(buyerRates.length, equals(1));
      expect(buyerRates.first.buyerId, equals('b1'));
      expect(buyerRates.first.productId, equals('p1'));
      expect(buyerRates.first.rate, equals(250));
    });

    testWidgets('renders RateFormSheet and saves supplier rate', (
      tester,
    ) async {
      await tester.pumpApp(
        const RateFormSheet(supplierId: 's1', productId: 'p1'),
        container: container,
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('rate_amount_field')), '220');
      await tester.tap(find.byKey(const Key('save_rate_button')));
      await tester.pumpAndSettle();

      final supplierRates = await repository
          .watchSupplierRatesForSupplier('s1')
          .first;
      expect(supplierRates.length, equals(1));
      expect(supplierRates.first.supplierId, equals('s1'));
      expect(supplierRates.first.productId, equals('p1'));
      expect(supplierRates.first.rate, equals(220));
    });
  });
}
