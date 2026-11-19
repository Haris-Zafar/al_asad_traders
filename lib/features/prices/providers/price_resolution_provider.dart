import 'package:al_asad_traders/features/prices/data/rates_repository.dart';
import 'package:al_asad_traders/features/prices/logic/price_resolution_rules.dart';
import 'package:al_asad_traders/features/products/providers/product_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parameters for resolving buyer or supplier price.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S7.
class PersonPriceParams {
  /// Creates [PersonPriceParams].
  const PersonPriceParams({
    required this.personId,
    required this.productId,
    required this.date,
  });

  /// Identifier of the buyer or supplier.
  final String personId;

  /// Identifier of the product.
  final String productId;

  /// Date string (yyyy-MM-dd) for price resolution.
  final String date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonPriceParams &&
          other.personId == personId &&
          other.productId == productId &&
          other.date == date;

  @override
  int get hashCode => Object.hash(personId, productId, date);
}

/// Parameters for resolving retail price.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S7.
class RetailPriceParams {
  /// Creates [RetailPriceParams].
  const RetailPriceParams({required this.productId, required this.date});

  /// Identifier of the product.
  final String productId;

  /// Date string (yyyy-MM-dd) for price resolution.
  final String date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetailPriceParams &&
          other.productId == productId &&
          other.date == date;

  @override
  int get hashCode => Object.hash(productId, date);
}

/// Provider to resolve effective buyer price for a product on a date.
/// Rule: wholesale_project.md > Prices. Story: S7.
final resolvedBuyerPriceProvider = StreamProvider.autoDispose
    .family<int, PersonPriceParams>((ref, params) {
      final repository = ref.watch(ratesRepositoryProvider);
      final productAsync = ref.watch(
        productDetailStreamProvider(params.productId),
      );
      final ratesStream = repository.watchBuyerRatesForBuyer(params.personId);

      return productAsync.when(
        data: (product) {
          final defaultPrice = product?.defaultBuyerRate ?? 0;
          return ratesStream.map(
            (rates) => PriceResolutionRules.resolveBuyerPrice(
              rates: rates,
              productId: params.productId,
              effectiveDate: params.date,
              defaultBuyerRate: defaultPrice,
            ),
          );
        },
        loading: () => Stream.value(0),
        error: (_, st) => Stream.value(0),
      );
    });

/// Provider to resolve effective supplier price for a product on a date.
/// Rule: wholesale_project.md > Prices. Story: S7.
final resolvedSupplierPriceProvider = StreamProvider.autoDispose
    .family<int, PersonPriceParams>((ref, params) {
      final repository = ref.watch(ratesRepositoryProvider);
      final productAsync = ref.watch(
        productDetailStreamProvider(params.productId),
      );
      final ratesStream = repository.watchSupplierRatesForSupplier(
        params.personId,
      );

      return productAsync.when(
        data: (product) {
          final defaultPrice = product?.defaultSupplierRate ?? 0;
          return ratesStream.map(
            (rates) => PriceResolutionRules.resolveSupplierPrice(
              rates: rates,
              productId: params.productId,
              effectiveDate: params.date,
              defaultSupplierRate: defaultPrice,
            ),
          );
        },
        loading: () => Stream.value(0),
        error: (_, st) => Stream.value(0),
      );
    });

/// Provider to resolve effective retail price for a product on a date.
/// Rule: wholesale_project.md > Prices. Story: S7.
final resolvedRetailPriceProvider = StreamProvider.autoDispose
    .family<int, RetailPriceParams>((ref, params) {
      final repository = ref.watch(ratesRepositoryProvider);
      final productAsync = ref.watch(
        productDetailStreamProvider(params.productId),
      );
      final pricesStream = repository.watchRetailPricesForProduct(
        params.productId,
      );

      return productAsync.when(
        data: (product) {
          final defaultPrice = product?.defaultRetailPrice ?? 0;
          return pricesStream.map(
            (prices) => PriceResolutionRules.resolveRetailPrice(
              prices: prices,
              productId: params.productId,
              effectiveDate: params.date,
              defaultRetailPrice: defaultPrice,
            ),
          );
        },
        loading: () => Stream.value(0),
        error: (_, st) => Stream.value(0),
      );
    });
