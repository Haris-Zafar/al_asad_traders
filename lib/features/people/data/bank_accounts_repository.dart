import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/people/models/bank_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [BankAccountsRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S10.
final Provider<BankAccountsRepository> bankAccountsRepositoryProvider =
    Provider<BankAccountsRepository>((ref) {
      return BankAccountsRepository(FirebaseFirestore.instance);
    });

/// Repository handling bank account records in Firestore.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S10.
class BankAccountsRepository {
  /// Creates a [BankAccountsRepository] with the given [firestore] instance.
  BankAccountsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _accountsRef =>
      _firestore.collection('bankAccounts');

  /// Stream of bank accounts for the business profile.
  /// Rule: docs/DATABASE.md > Key queries. Story: S10.
  Stream<List<BankAccount>> watchProfileBankAccounts() {
    return _accountsRef
        .where('profileId', isEqualTo: 'main')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BankAccount.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Stream of bank accounts for a specific buyer.
  /// Rule: docs/DATABASE.md > Key queries. Story: S10.
  Stream<List<BankAccount>> watchBuyerBankAccounts(String buyerId) {
    return _accountsRef
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BankAccount.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Stream of bank accounts for a specific supplier.
  /// Rule: docs/DATABASE.md > Key queries. Story: S10.
  Stream<List<BankAccount>> watchSupplierBankAccounts(String supplierId) {
    return _accountsRef
        .where('supplierId', isEqualTo: supplierId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BankAccount.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Saves (creates or updates) a bank account record.
  /// Enforces that exactly one owner ID is set.
  /// Rule: docs/ARCHITECTURE.md > Writes and offline. Story: S10.
  Future<void> saveBankAccount(BankAccount account) async {
    try {
      if (account.name.trim().isEmpty) {
        throw const ValidationException('Bank name cannot be empty');
      }
      if (account.accountNumber.trim().isEmpty) {
        throw const ValidationException('Account number cannot be empty');
      }
      if (!account.hasValidOwner) {
        throw const ValidationException(
          'Bank account must belong to exactly one owner (profile, buyer, or supplier)',
        );
      }

      if (account.id.isEmpty) {
        final docRef = _accountsRef.doc();
        final newAccount = account.copyWith(
          id: docRef.id,
          createdAt: account.createdAt,
        );
        await docRef.set(newAccount.toMap());
      } else {
        await _accountsRef
            .doc(account.id)
            .set(account.toMap(), SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Archives a bank account by setting [archivedAt].
  /// Rule: wholesale_project.md > Archiving. Story: S10.
  Future<void> archiveBankAccount(String accountId) async {
    try {
      await _accountsRef.doc(accountId).update(<String, dynamic>{
        'archivedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Unarchives a bank account by clearing [archivedAt].
  /// Rule: wholesale_project.md > Archiving. Story: S10.
  Future<void> unarchiveBankAccount(String accountId) async {
    try {
      await _accountsRef.doc(accountId).update(<String, dynamic>{
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
