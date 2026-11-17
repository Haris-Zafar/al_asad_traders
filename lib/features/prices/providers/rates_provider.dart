import 'package:al_asad_traders/features/prices/data/rates_repository.dart';
import 'package:al_asad_traders/features/prices/models/buyer_rate.dart';
import 'package:al_asad_traders/features/prices/models/supplier_rate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for buyer rates of a specific buyer.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final AutoDisposeStreamProviderFamily<List<BuyerRate>, String>
buyerRatesForBuyerProvider = StreamProvider.family.autoDispose<
  List<BuyerRate>,
  String
>((ref, buyerId) {
  final repository = ref.watch(ratesRepositoryProvider);
  return repository.watchBuyerRatesForBuyer(buyerId);
});

/// Stream provider for buyer rates of a specific product.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final AutoDisposeStreamProviderFamily<List<BuyerRate>, String>
buyerRatesForProductProvider = StreamProvider.family.autoDispose<
  List<BuyerRate>,
  String
>((ref, productId) {
  final repository = ref.watch(ratesRepositoryProvider);
  return repository.watchBuyerRatesForProduct(productId);
});

/// Stream provider for supplier rates of a specific supplier.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final AutoDisposeStreamProviderFamily<List<SupplierRate>, String>
supplierRatesForSupplierProvider = StreamProvider.family.autoDispose<
  List<SupplierRate>,
  String
>((ref, supplierId) {
  final repository = ref.watch(ratesRepositoryProvider);
  return repository.watchSupplierRatesForSupplier(supplierId);
});

/// Stream provider for supplier rates of a specific product.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final AutoDisposeStreamProviderFamily<List<SupplierRate>, String>
supplierRatesForProductProvider = StreamProvider.family.autoDispose<
  List<SupplierRate>,
  String
>((ref, productId) {
  final repository = ref.watch(ratesRepositoryProvider);
  return repository.watchSupplierRatesForProduct(productId);
});
