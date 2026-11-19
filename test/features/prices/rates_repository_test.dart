import 'package:al_asad_traders/features/prices/data/rates_repository.dart';
import 'package:al_asad_traders/features/prices/models/buyer_rate.dart';
import 'package:al_asad_traders/features/prices/models/supplier_rate.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RatesRepository (S5, T-16)', () {
    late FakeFirebaseFirestore firestore;
    late RatesRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = RatesRepository(firestore);
    });

    test('saveBuyerRate saves buyer rate with composite ID', () async {
      final rate = BuyerRate(
        id: '',
        buyerId: 'b1',
        productId: 'p1',
        rate: 150,
        effectiveDate: '2026-11-10',
        createdAt: DateTime(2026, 11, 10, 10, 0),
      );

      await repository.saveBuyerRate(rate);

      final buyerRates = await repository.watchBuyerRatesForBuyer('b1').first;
      expect(buyerRates.length, equals(1));
      expect(buyerRates.first.id, equals('b1_p1_2026-11-10'));
      expect(buyerRates.first.rate, equals(150));
      expect(buyerRates.first.effectiveDate, equals('2026-11-10'));

      final productRates = await repository
          .watchBuyerRatesForProduct('p1')
          .first;
      expect(productRates.length, equals(1));
      expect(productRates.first.id, equals('b1_p1_2026-11-10'));
    });

    test(
      'saveBuyerRate same-day rate overwrite replaces existing rate',
      () async {
        final rate1 = BuyerRate(
          id: '',
          buyerId: 'b1',
          productId: 'p1',
          rate: 150,
          effectiveDate: '2026-11-10',
          createdAt: DateTime(2026, 11, 10, 10, 0),
        );
        await repository.saveBuyerRate(rate1);

        final rate2 = BuyerRate(
          id: '',
          buyerId: 'b1',
          productId: 'p1',
          rate: 165,
          effectiveDate: '2026-11-10',
          createdAt: DateTime(2026, 11, 10, 14, 0),
        );
        await repository.saveBuyerRate(rate2);

        final buyerRates = await repository.watchBuyerRatesForBuyer('b1').first;
        expect(buyerRates.length, equals(1));
        expect(buyerRates.first.id, equals('b1_p1_2026-11-10'));
        expect(buyerRates.first.rate, equals(165));
      },
    );

    test('saveSupplierRate saves supplier rate with composite ID', () async {
      final rate = SupplierRate(
        id: '',
        supplierId: 's1',
        productId: 'p1',
        rate: 140,
        effectiveDate: '2026-11-10',
        createdAt: DateTime(2026, 11, 10, 10, 0),
      );

      await repository.saveSupplierRate(rate);

      final supplierRates = await repository
          .watchSupplierRatesForSupplier('s1')
          .first;
      expect(supplierRates.length, equals(1));
      expect(supplierRates.first.id, equals('s1_p1_2026-11-10'));
      expect(supplierRates.first.rate, equals(140));

      final productRates = await repository
          .watchSupplierRatesForProduct('p1')
          .first;
      expect(productRates.length, equals(1));
      expect(productRates.first.id, equals('s1_p1_2026-11-10'));
    });

    test(
      'saveSupplierRate same-day rate overwrite replaces existing rate',
      () async {
        final rate1 = SupplierRate(
          id: '',
          supplierId: 's1',
          productId: 'p1',
          rate: 140,
          effectiveDate: '2026-11-10',
          createdAt: DateTime(2026, 11, 10, 10, 0),
        );
        await repository.saveSupplierRate(rate1);

        final rate2 = SupplierRate(
          id: '',
          supplierId: 's1',
          productId: 'p1',
          rate: 148,
          effectiveDate: '2026-11-10',
          createdAt: DateTime(2026, 11, 10, 16, 0),
        );
        await repository.saveSupplierRate(rate2);

        final supplierRates = await repository
            .watchSupplierRatesForSupplier('s1')
            .first;
        expect(supplierRates.length, equals(1));
        expect(supplierRates.first.id, equals('s1_p1_2026-11-10'));
        expect(supplierRates.first.rate, equals(148));
      },
    );

    test(
      'deleteBuyerRate and deleteSupplierRate removes rate documents',
      () async {
        final buyerRate = BuyerRate(
          id: '',
          buyerId: 'b1',
          productId: 'p1',
          rate: 150,
          effectiveDate: '2026-11-10',
          createdAt: DateTime.now(),
        );
        await repository.saveBuyerRate(buyerRate);

        final supplierRate = SupplierRate(
          id: '',
          supplierId: 's1',
          productId: 'p1',
          rate: 140,
          effectiveDate: '2026-11-10',
          createdAt: DateTime.now(),
        );
        await repository.saveSupplierRate(supplierRate);

        await repository.deleteBuyerRate('b1_p1_2026-11-10');
        await repository.deleteSupplierRate('s1_p1_2026-11-10');

        final buyerRates = await repository.watchBuyerRatesForBuyer('b1').first;
        final supplierRates = await repository
            .watchSupplierRatesForSupplier('s1')
            .first;

        expect(buyerRates, isEmpty);
        expect(supplierRates, isEmpty);
      },
    );
  });
}
