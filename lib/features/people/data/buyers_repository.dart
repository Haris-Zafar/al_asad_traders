import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/people/models/buyer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [BuyersRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final Provider<BuyersRepository> buyersRepositoryProvider =
    Provider<BuyersRepository>((ref) {
      return BuyersRepository(FirebaseFirestore.instance);
    });

/// Repository handling buyer records in Firestore.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S9.
class BuyersRepository {
  /// Creates a [BuyersRepository] with the given [firestore] instance.
  BuyersRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _buyersRef =>
      _firestore.collection('buyers');

  /// Stream of all buyers in the system.
  /// Rule: docs/DATABASE.md > Key queries. Story: S9.
  Stream<List<Buyer>> watchBuyers() {
    return _buyersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Buyer.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Retrieves a single buyer by [id].
  /// Rule: docs/ARCHITECTURE.md > Repository. Story: S9.
  Future<Buyer?> getBuyer(String id) async {
    try {
      final snapshot = await _buyersRef.doc(id).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Buyer.fromMap(snapshot.data()!, snapshot.id);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Saves (creates or updates) a buyer record.
  /// Rule: docs/ARCHITECTURE.md > Writes and offline. Story: S9.
  Future<void> saveBuyer(Buyer buyer) async {
    try {
      if (buyer.name.trim().isEmpty) {
        throw const ValidationException('Name cannot be empty');
      }
      if (buyer.id.isEmpty) {
        final docRef = _buyersRef.doc();
        final newBuyer = buyer.copyWith(
          id: docRef.id,
          createdAt: buyer.createdAt,
        );
        await docRef.set(newBuyer.toMap());
      } else {
        await _buyersRef
            .doc(buyer.id)
            .set(buyer.toMap(), SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Checks if archiving [buyerId] produces warnings (non-zero balance, active bills, open demands).
  /// Rule: wholesale_project.md > Archiving. Story: S9.
  Future<List<String>> checkArchiveWarnings(String buyerId) async {
    final warnings = <String>[];
    try {
      // 1. Check ledger entries balance
      final ledgerSnap = await _firestore
          .collection('ledgerEntries')
          .where('buyerId', isEqualTo: buyerId)
          .get();
      int balance = 0;
      for (final doc in ledgerSnap.docs) {
        final amount = doc.data()['amount'] as int? ?? 0;
        balance += amount;
      }
      if (balance != 0) {
        warnings.add('Buyer has a non-zero ledger balance');
      }

      // 2. Check draft or issued bills
      final billsSnap = await _firestore
          .collection('bills')
          .where('buyerId', isEqualTo: buyerId)
          .get();
      final hasActiveBills = billsSnap.docs.any((doc) {
        final status = doc.data()['status'] as String? ?? '';
        return status == 'draft' || status == 'issued';
      });
      if (hasActiveBills) {
        warnings.add('Buyer has draft or issued bills');
      }

      // 3. Check open demands
      final demandsSnap = await _firestore
          .collection('demands')
          .where('buyerId', isEqualTo: buyerId)
          .get();
      final hasOpenDemands = demandsSnap.docs.any((doc) {
        final status = doc.data()['status'] as String? ?? '';
        return status == 'open';
      });
      if (hasOpenDemands) {
        warnings.add('Buyer has open demands');
      }
    } catch (_) {
      // Return accumulated warnings if query completes
    }
    return warnings;
  }

  /// Hides/archives a buyer by setting [archivedAt].
  /// Rule: wholesale_project.md > Archiving. Story: S9.
  Future<void> archiveBuyer(String buyerId) async {
    try {
      await _buyersRef.doc(buyerId).update(<String, dynamic>{
        'archivedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Unhides/unarchives a buyer by clearing [archivedAt].
  /// Rule: wholesale_project.md > Archiving. Story: S9.
  Future<void> unarchiveBuyer(String buyerId) async {
    try {
      await _buyersRef.doc(buyerId).update(<String, dynamic>{
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
