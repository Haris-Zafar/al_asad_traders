import 'package:al_asad_traders/features/prices/logic/price_resolution_rules.dart';
import 'package:al_asad_traders/features/prices/models/buyer_rate.dart';
import 'package:al_asad_traders/features/prices/models/retail_price.dart';
import 'package:al_asad_traders/features/prices/models/supplier_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceResolutionRules (S7, T-18)', () {
    test(
      'resolveBuyerPrice returns default when no rates match or list is empty',
      () {
        final price = PriceResolutionRules.resolveBuyerPrice(
          rates: [],
          productId: 'p1',
          effectiveDate: '2026-11-10',
          defaultBuyerRate: 200,
        );
        expect(price, equals(200));

        final rateOld = BuyerRate(
          id: 'b1_p1_2026-11-15',
          buyerId: 'b1',
          productId: 'p1',
          rate: 250,
          effectiveDate: '2026-11-15',
          createdAt: DateTime(2026, 11, 15),
        );

        final priceFuture = PriceResolutionRules.resolveBuyerPrice(
          rates: [rateOld],
          productId: 'p1',
          effectiveDate: '2026-11-10',
          defaultBuyerRate: 200,
        );
        expect(priceFuture, equals(200));
      },
    );

    test('resolveBuyerPrice selects latest rate with effectiveDate <= D', () {
      final r1 = BuyerRate(
        id: 'b1_p1_2026-11-01',
        buyerId: 'b1',
        productId: 'p1',
        rate: 210,
        effectiveDate: '2026-11-01',
        createdAt: DateTime(2026, 11, 1),
      );
      final r2 = BuyerRate(
        id: 'b1_p1_2026-11-05',
        buyerId: 'b1',
        productId: 'p1',
        rate: 220,
        effectiveDate: '2026-11-05',
        createdAt: DateTime(2026, 11, 5),
      );
      final r3 = BuyerRate(
        id: 'b1_p1_2026-11-12',
        buyerId: 'b1',
        productId: 'p1',
        rate: 230,
        effectiveDate: '2026-11-12',
        createdAt: DateTime(2026, 11, 12),
      );

      final price = PriceResolutionRules.resolveBuyerPrice(
        rates: [r1, r2, r3],
        productId: 'p1',
        effectiveDate: '2026-11-10',
        defaultBuyerRate: 200,
      );
      expect(price, equals(220));

      final price2 = PriceResolutionRules.resolveBuyerPrice(
        rates: [r1, r2, r3],
        productId: 'p1',
        effectiveDate: '2026-11-15',
        defaultBuyerRate: 200,
      );
      expect(price2, equals(230));
    });

    test(
      'resolveSupplierPrice selects latest rate with effectiveDate <= D',
      () {
        final s1 = SupplierRate(
          id: 's1_p1_2026-11-02',
          supplierId: 's1',
          productId: 'p1',
          rate: 150,
          effectiveDate: '2026-11-02',
          createdAt: DateTime(2026, 11, 2),
        );
        final s2 = SupplierRate(
          id: 's1_p1_2026-11-08',
          supplierId: 's1',
          productId: 'p1',
          rate: 160,
          effectiveDate: '2026-11-08',
          createdAt: DateTime(2026, 11, 8),
        );

        final price = PriceResolutionRules.resolveSupplierPrice(
          rates: [s1, s2],
          productId: 'p1',
          effectiveDate: '2026-11-08',
          defaultSupplierRate: 140,
        );
        expect(price, equals(160));
      },
    );

    test('resolveRetailPrice selects latest price with effectiveDate <= D', () {
      final p1 = RetailPrice(
        id: 'p1_2026-11-01',
        productId: 'p1',
        price: 300,
        effectiveDate: '2026-11-01',
        createdAt: DateTime(2026, 11, 1),
      );
      final p2 = RetailPrice(
        id: 'p1_2026-11-06',
        productId: 'p1',
        price: 320,
        effectiveDate: '2026-11-06',
        createdAt: DateTime(2026, 11, 6),
      );

      final price = PriceResolutionRules.resolveRetailPrice(
        prices: [p1, p2],
        productId: 'p1',
        effectiveDate: '2026-11-06',
        defaultRetailPrice: 280,
      );
      expect(price, equals(320));
    });
  });
}
