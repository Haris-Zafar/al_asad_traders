import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [ProductRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1, S4.
final Provider<ProductRepository> productRepositoryProvider =
    Provider<ProductRepository>((ref) {
      return ProductRepository(FirebaseFirestore.instance);
    });

/// Repository handling product records in Firestore.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S1, S4.
class ProductRepository {
  /// Creates a [ProductRepository] with the given [firestore] instance.
  ProductRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  /// Stream of all products in the system.
  /// Rule: docs/DATABASE.md > Key queries. Story: S1.
  Stream<List<Product>> watchProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Retrieves a single product by [id].
  /// Rule: docs/ARCHITECTURE.md > Repository. Story: S1.
  Future<Product?> getProduct(String id) async {
    try {
      final snapshot = await _productsRef.doc(id).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Product.fromMap(snapshot.data()!, snapshot.id);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Retrieves a product by its barcode [sku] via `productSkus` collection lookup.
  /// Rule: docs/DATABASE.md > Key queries. Story: S2.
  Future<Product?> getProductBySku(String sku) async {
    try {
      final skuDoc = await _firestore.collection('productSkus').doc(sku).get();
      if (!skuDoc.exists || skuDoc.data() == null) {
        return null;
      }
      final productId = skuDoc.data()!['productId'] as String?;
      if (productId == null || productId.isEmpty) {
        return null;
      }
      return await getProduct(productId);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Saves (creates or updates) a product record and batches `productSkus` creation/deletion.
  /// Returns the product ID.
  /// Rule: docs/DATABASE.md > Atomic operations. Story: S1, S2.
  Future<String> saveProduct(Product product) async {
    try {
      if (product.name.trim().isEmpty) {
        throw const ValidationException('Name cannot be empty');
      }
      if (product.defaultSupplierRate < 0 ||
          product.defaultBuyerRate < 0 ||
          product.defaultRetailPrice < 0) {
        throw const ValidationException('Prices cannot be negative');
      }

      final String productId = product.id.isNotEmpty
          ? product.id
          : _productsRef.doc().id;
      final docRef = _productsRef.doc(productId);

      Product? existingProduct;
      final existingSnap = await docRef.get();
      if (existingSnap.exists && existingSnap.data() != null) {
        existingProduct = Product.fromMap(existingSnap.data()!, productId);
      }

      final finalProduct = product.copyWith(
        id: productId,
        createdAt: existingProduct?.createdAt ?? product.createdAt,
      );

      final batch = _firestore.batch();
      batch.set(docRef, finalProduct.toMap(), SetOptions(merge: true));

      final oldSku = existingProduct?.sku;
      final newSku = finalProduct.sku?.trim().isEmpty ?? true
          ? null
          : finalProduct.sku!.trim();

      if (oldSku != newSku) {
        if (oldSku != null && oldSku.isNotEmpty) {
          batch.delete(_firestore.doc('productSkus/$oldSku'));
          try {
            await _firestore.doc('productSkus/$oldSku').delete();
          } catch (_) {}
        }
        if (newSku != null && newSku.isNotEmpty) {
          batch.set(_firestore.doc('productSkus/$newSku'), <String, dynamic>{
            'productId': productId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      return productId;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Checks if archiving [productId] produces warnings (linked active demands, summary items, or bills).
  /// Rule: wholesale_project.md > Archiving. Story: S4.
  Future<List<String>> checkArchiveWarnings(String productId) async {
    final warnings = <String>[];
    try {
      final demandItemsSnap = await _firestore
          .collection('demandItems')
          .where('productId', isEqualTo: productId)
          .get();
      if (demandItemsSnap.docs.isNotEmpty) {
        warnings.add('Product has active demand items');
      }

      final summaryItemsSnap = await _firestore
          .collection('summaryItems')
          .where('productId', isEqualTo: productId)
          .get();
      if (summaryItemsSnap.docs.isNotEmpty) {
        warnings.add('Product has active buying list items');
      }

      final billItemsSnap = await _firestore
          .collection('billItems')
          .where('productId', isEqualTo: productId)
          .get();
      if (billItemsSnap.docs.isNotEmpty) {
        warnings.add('Product is referenced in bills');
      }
    } catch (_) {
      // Ignore query errors during archive warning check
    }
    return warnings;
  }

  AppException _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const PermissionException(AppStrings.errorPleaseLogInAgain);
      case 'unavailable':
      case 'network-request-failed':
        return const UnavailableException(AppStrings.errorInternetNeeded);
      default:
        return UnknownException(AppStrings.errorGeneric, e);
    }
  }
}
