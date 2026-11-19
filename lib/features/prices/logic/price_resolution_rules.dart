import 'package:al_asad_traders/features/prices/models/buyer_rate.dart';
import 'package:al_asad_traders/features/prices/models/retail_price.dart';
import 'package:al_asad_traders/features/prices/models/supplier_rate.dart';

/// Pure rules for resolving effective product prices for buyers, suppliers, and retail on date D.
/// Rule: wholesale_project.md > Prices. Story: S7.
class PriceResolutionRules {
  /// Resolves the effective buyer price for a product on date [effectiveDate] (yyyy-MM-dd).
  /// Returns the rate of the latest buyer rate entry where effectiveDate <= date D,
  /// or falls back to [defaultBuyerRate] if no matching rate exists.
  /// Rule: wholesale_project.md > Prices. Story: S7.
  static int resolveBuyerPrice({
    required List<BuyerRate> rates,
    required String productId,
    required String effectiveDate,
    required int defaultBuyerRate,
  }) {
    final productRates = rates
        .where(
          (r) =>
              r.productId == productId &&
              r.effectiveDate.compareTo(effectiveDate) <= 0,
        )
        .toList();

    if (productRates.isEmpty) {
      return defaultBuyerRate;
    }

    productRates.sort((a, b) {
      final dateCmp = b.effectiveDate.compareTo(a.effectiveDate);
      if (dateCmp != 0) return dateCmp;
      return b.createdAt.compareTo(a.createdAt);
    });

    return productRates.first.rate;
  }

  /// Resolves the effective supplier price for a product on date [effectiveDate] (yyyy-MM-dd).
  /// Returns the rate of the latest supplier rate entry where effectiveDate <= date D,
  /// or falls back to [defaultSupplierRate] if no matching rate exists.
  /// Rule: wholesale_project.md > Prices. Story: S7.
  static int resolveSupplierPrice({
    required List<SupplierRate> rates,
    required String productId,
    required String effectiveDate,
    required int defaultSupplierRate,
  }) {
    final productRates = rates
        .where(
          (r) =>
              r.productId == productId &&
              r.effectiveDate.compareTo(effectiveDate) <= 0,
        )
        .toList();

    if (productRates.isEmpty) {
      return defaultSupplierRate;
    }

    productRates.sort((a, b) {
      final dateCmp = b.effectiveDate.compareTo(a.effectiveDate);
      if (dateCmp != 0) return dateCmp;
      return b.createdAt.compareTo(a.createdAt);
    });

    return productRates.first.rate;
  }

  /// Resolves the effective retail price for a product on date [effectiveDate] (yyyy-MM-dd).
  /// Returns the price of the latest retail price entry where effectiveDate <= date D,
  /// or falls back to [defaultRetailPrice] if no matching price exists.
  /// Rule: wholesale_project.md > Prices. Story: S7.
  static int resolveRetailPrice({
    required List<RetailPrice> prices,
    required String productId,
    required String effectiveDate,
    required int defaultRetailPrice,
  }) {
    final productPrices = prices
        .where(
          (p) =>
              p.productId == productId &&
              p.effectiveDate.compareTo(effectiveDate) <= 0,
        )
        .toList();

    if (productPrices.isEmpty) {
      return defaultRetailPrice;
    }

    productPrices.sort((a, b) {
      final dateCmp = b.effectiveDate.compareTo(a.effectiveDate);
      if (dateCmp != 0) return dateCmp;
      return b.createdAt.compareTo(a.createdAt);
    });

    return productPrices.first.price;
  }
}
