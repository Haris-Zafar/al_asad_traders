import 'package:al_asad_traders/features/prices/data/rates_repository.dart';
import 'package:al_asad_traders/features/prices/models/buyer_rate.dart';
import 'package:al_asad_traders/features/prices/models/retail_price.dart';
import 'package:al_asad_traders/features/prices/models/supplier_rate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for buyer rates of a specific buyer.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final buyerRatesForBuyerProvider = StreamProvider.autoDispose
    .family<List<BuyerRate>, String>((ref, buyerId) {
      final repository = ref.watch(ratesRepositoryProvider);
      return repository.watchBuyerRatesForBuyer(buyerId);
    });

/// Stream provider for buyer rates of a specific product.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final buyerRatesForProductProvider = StreamProvider.autoDispose
    .family<List<BuyerRate>, String>((ref, productId) {
      final repository = ref.watch(ratesRepositoryProvider);
      return repository.watchBuyerRatesForProduct(productId);
    });

/// Stream provider for supplier rates of a specific supplier.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final supplierRatesForSupplierProvider = StreamProvider.autoDispose
    .family<List<SupplierRate>, String>((ref, supplierId) {
      final repository = ref.watch(ratesRepositoryProvider);
      return repository.watchSupplierRatesForSupplier(supplierId);
    });

/// Stream provider for supplier rates of a specific product.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final supplierRatesForProductProvider = StreamProvider.autoDispose
    .family<List<SupplierRate>, String>((ref, productId) {
      final repository = ref.watch(ratesRepositoryProvider);
      return repository.watchSupplierRatesForProduct(productId);
    });

/// Stream provider for retail prices of a specific product.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S6.
final retailPricesForProductProvider = StreamProvider.autoDispose
    .family<List<RetailPrice>, String>((ref, productId) {
      final repository = ref.watch(ratesRepositoryProvider);
      return repository.watchRetailPricesForProduct(productId);
    });
