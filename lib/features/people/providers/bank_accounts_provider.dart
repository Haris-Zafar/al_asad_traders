import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/people/data/bank_accounts_repository.dart';
import 'package:al_asad_traders/features/people/models/bank_account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for business profile bank accounts.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S10.
final profileBankAccountsStreamProvider =
    StreamProvider.autoDispose<List<BankAccount>>((ref) {
      final repository = ref.watch(bankAccountsRepositoryProvider);
      return repository.watchProfileBankAccounts();
    });

/// Stream provider for a buyer's bank accounts.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S10.
final buyerBankAccountsStreamProvider = StreamProvider.autoDispose
    .family<List<BankAccount>, String>((ref, buyerId) {
      final repository = ref.watch(bankAccountsRepositoryProvider);
      return repository.watchBuyerBankAccounts(buyerId);
    });

/// Stream provider for a supplier's bank accounts.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S10.
final supplierBankAccountsStreamProvider = StreamProvider.autoDispose
    .family<List<BankAccount>, String>((ref, supplierId) {
      final repository = ref.watch(bankAccountsRepositoryProvider);
      return repository.watchSupplierBankAccounts(supplierId);
    });

/// Controller managing bank account mutations.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S10.
class BankAccountController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Saves a bank account.
  Future<void> saveBankAccount(BankAccount account) async {
    if (account.name.trim().isEmpty) {
      state = AsyncValue.error(
        const ValidationException('Bank name cannot be empty'),
        StackTrace.current,
      );
      return;
    }
    if (account.accountNumber.trim().isEmpty) {
      state = AsyncValue.error(
        const ValidationException('Account number cannot be empty'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(bankAccountsRepositoryProvider);
      await repository.saveBankAccount(account);
    });
    if (ref.mounted) {
      state = result;
    }
  }

  /// Toggles archive status of a bank account.
  Future<void> toggleArchive(BankAccount account) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(bankAccountsRepositoryProvider);
      if (account.isArchived) {
        await repository.unarchiveBankAccount(account.id);
      } else {
        await repository.archiveBankAccount(account.id);
      }
    });
    if (ref.mounted) {
      state = result;
    }
  }
}

/// Provider for [BankAccountController].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S10.
final bankAccountControllerProvider =
    NotifierProvider<BankAccountController, AsyncValue<void>>(
      BankAccountController.new,
    );
