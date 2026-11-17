import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/prices/models/buyer_rate.dart';
import 'package:al_asad_traders/features/prices/models/supplier_rate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [RatesRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S5.
final Provider<RatesRepository> ratesRepositoryProvider =
    Provider<RatesRepository>((ref) {
      return RatesRepository(FirebaseFirestore.instance);
    });

/// Repository handling buyer and supplier rate records in Firestore.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S5.
class RatesRepository {
  /// Creates a [RatesRepository] with the given [firestore] instance.
  RatesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _buyerRatesRef =>
      _firestore.collection('buyerRates');

  CollectionReference<Map<String, dynamic>> get _supplierRatesRef =>
      _firestore.collection('supplierRates');

  /// Saves or overwrites a buyer rate entry.
  /// Rule: docs/DATABASE.md > Collections (buyerRates). Story: S5.
  Future<void> saveBuyerRate(BuyerRate rate) async {
    try {
      final docId = BuyerRate.buildDocId(
        rate.buyerId,
        rate.productId,
        rate.effectiveDate,
      );
      final rateWithId = rate.copyWith(id: docId);
      await _buyerRatesRef.doc(docId).set(rateWithId.toMap());
    } catch (e) {
      throw AppException(AppStrings.somethingWentWrong);
    }
  }

  /// Saves or overwrites a supplier rate entry.
  /// Rule: docs/DATABASE.md > Collections (supplierRates). Story: S5.
  Future<void> saveSupplierRate(SupplierRate rate) async {
    try {
      final docId = SupplierRate.buildDocId(
        rate.supplierId,
        rate.productId,
        rate.effectiveDate,
      );
      final rateWithId = rate.copyWith(id: docId);
      await _supplierRatesRef.doc(docId).set(rateWithId.toMap());
    } catch (e) {
      throw AppException(AppStrings.somethingWentWrong);
    }
  }

  /// Stream of buyer rates for a specific buyer, sorted newest effective date first.
  /// Rule: docs/DATABASE.md > Key queries. Story: S5.
  Stream<List<BuyerRate>> watchBuyerRatesForBuyer(String buyerId) {
    return _buyerRatesRef
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
          final list =
              snapshot.docs.map((doc) => BuyerRate.fromDocument(doc)).toList();
          list.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
          return list;
        });
  }

  /// Stream of buyer rates for a specific product, sorted newest effective date first.
  /// Rule: docs/DATABASE.md > Key queries. Story: S5.
  Stream<List<BuyerRate>> watchBuyerRatesForProduct(String productId) {
    return _buyerRatesRef
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          final list =
              snapshot.docs.map((doc) => BuyerRate.fromDocument(doc)).toList();
          list.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
          return list;
        });
  }

  /// Stream of supplier rates for a specific supplier, sorted newest effective date first.
  /// Rule: docs/DATABASE.md > Key queries. Story: S5.
  Stream<List<SupplierRate>> watchSupplierRatesForSupplier(String supplierId) {
    return _supplierRatesRef
        .where('supplierId', isEqualTo: supplierId)
        .snapshots()
        .map((snapshot) {
          final list =
              snapshot.docs
                  .map((doc) => SupplierRate.fromDocument(doc))
                  .toList();
          list.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
          return list;
        });
  }

  /// Stream of supplier rates for a specific product, sorted newest effective date first.
  /// Rule: docs/DATABASE.md > Key queries. Story: S5.
  Stream<List<SupplierRate>> watchSupplierRatesForProduct(String productId) {
    return _supplierRatesRef
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          final list =
              snapshot.docs
                  .map((doc) => SupplierRate.fromDocument(doc))
                  .toList();
          list.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
          return list;
        });
  }

  /// Deletes a buyer rate by document ID.
  /// Rule: docs/DATABASE.md > Collections. Story: S5.
  Future<void> deleteBuyerRate(String id) async {
    try {
      await _buyerRatesRef.doc(id).delete();
    } catch (e) {
      throw AppException(AppStrings.somethingWentWrong);
    }
  }

  /// Deletes a supplier rate by document ID.
  /// Rule: docs/DATABASE.md > Collections. Story: S5.
  Future<void> deleteSupplierRate(String id) async {
    try {
      await _supplierRatesRef.doc(id).delete();
    } catch (e) {
      throw AppException(AppStrings.somethingWentWrong);
    }
  }
}
