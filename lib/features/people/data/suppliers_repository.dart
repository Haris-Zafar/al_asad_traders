import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [SuppliersRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final Provider<SuppliersRepository> suppliersRepositoryProvider =
    Provider<SuppliersRepository>((ref) {
      return SuppliersRepository(FirebaseFirestore.instance);
    });

/// Repository handling supplier records in Firestore.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S9.
class SuppliersRepository {
  /// Creates a [SuppliersRepository] with the given [firestore] instance.
  SuppliersRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _suppliersRef =>
      _firestore.collection('suppliers');

  /// Stream of all suppliers in the system.
  /// Rule: docs/DATABASE.md > Key queries. Story: S9.
  Stream<List<Supplier>> watchSuppliers() {
    return _suppliersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Supplier.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Retrieves a single supplier by [id].
  /// Rule: docs/ARCHITECTURE.md > Repository. Story: S9.
  Future<Supplier?> getSupplier(String id) async {
    try {
      final snapshot = await _suppliersRef.doc(id).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Supplier.fromMap(snapshot.data()!, snapshot.id);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Saves (creates or updates) a supplier record.
  /// Rule: docs/ARCHITECTURE.md > Writes and offline. Story: S9.
  Future<void> saveSupplier(Supplier supplier) async {
    try {
      if (supplier.name.trim().isEmpty) {
        throw const ValidationException('Name cannot be empty');
      }
      if (supplier.id.isEmpty) {
        final docRef = _suppliersRef.doc();
        final newSupplier = supplier.copyWith(
          id: docRef.id,
          createdAt: supplier.createdAt,
        );
        await docRef.set(newSupplier.toMap());
      } else {
        await _suppliersRef
            .doc(supplier.id)
            .set(supplier.toMap(), SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Checks if archiving [supplierId] produces warnings (open purchase lists).
  /// Rule: wholesale_project.md > Archiving. Story: S9.
  Future<List<String>> checkArchiveWarnings(String supplierId) async {
    final warnings = <String>[];
    try {
      final summariesSnap = await _firestore
          .collection('summaries')
          .where('supplierId', isEqualTo: supplierId)
          .get();
      final hasOpenLists = summariesSnap.docs.any((doc) {
        final status = doc.data()['status'] as String? ?? '';
        return status == 'open';
      });
      if (hasOpenLists) {
        warnings.add('Supplier has open purchase lists');
      }
    } catch (_) {
      // Return accumulated warnings if query completes
    }
    return warnings;
  }

  /// Hides/archives a supplier by setting [archivedAt].
  /// Rule: wholesale_project.md > Archiving. Story: S9.
  Future<void> archiveSupplier(String supplierId) async {
    try {
      await _suppliersRef.doc(supplierId).update(<String, dynamic>{
        'archivedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Unhides/unarchives a supplier by clearing [archivedAt].
  /// Rule: wholesale_project.md > Archiving. Story: S9.
  Future<void> unarchiveSupplier(String supplierId) async {
    try {
      await _suppliersRef.doc(supplierId).update(<String, dynamic>{
        'archivedAt': null,
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
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
