import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_dialogs.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/loading_view.dart';
import 'package:al_asad_traders/features/people/models/bank_account.dart';
import 'package:al_asad_traders/features/people/providers/bank_accounts_provider.dart';
import 'package:al_asad_traders/features/people/ui/bank_account_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal sheet displaying list of bank accounts for profile, buyer, or supplier.
/// Rule: docs/UI_PLAN.md > Small tasks use bottom sheets. Story: S10.
class BankAccountsListSheet extends ConsumerWidget {
  /// Creates a [BankAccountsListSheet].
  const BankAccountsListSheet({
    super.key,
    this.profileId,
    this.buyerId,
    this.supplierId,
    required this.ownerName,
  });

  /// Optional owner profile ID ('main').
  final String? profileId;

  /// Optional owner buyer ID.
  final String? buyerId;

  /// Optional owner supplier ID.
  final String? supplierId;

  /// Display name of the owner for sheet title.
  final String ownerName;

  /// Shows the [BankAccountsListSheet] in a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    String? profileId,
    String? buyerId,
    String? supplierId,
    required String ownerName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: BankAccountsListSheet(
          profileId: profileId,
          buyerId: buyerId,
          supplierId: supplierId,
          ownerName: ownerName,
        ),
      ),
    );
  }

  Future<void> _handleArchiveToggle(
    BuildContext context,
    WidgetRef ref,
    BankAccount account,
  ) async {
    if (account.isArchived) {
      await ref
          .read(bankAccountControllerProvider.notifier)
          .toggleArchive(account);
    } else {
      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.archiveBankAccountTitle,
        message: AppStrings.archiveBankAccountWarning,
        confirmLabel: AppStrings.confirmHide,
        isDanger: true,
      );

      if (confirmed == true && context.mounted) {
        await ref
            .read(bankAccountControllerProvider.notifier)
            .toggleArchive(account);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AsyncValue<List<BankAccount>> accountsAsync;

    if (profileId != null) {
      accountsAsync = ref.watch(profileBankAccountsStreamProvider);
    } else if (buyerId != null) {
      accountsAsync = ref.watch(buyerBankAccountsStreamProvider(buyerId!));
    } else if (supplierId != null) {
      accountsAsync = ref.watch(
        supplierBankAccountsStreamProvider(supplierId!),
      );
    } else {
      accountsAsync = const AsyncValue.data([]);
    }

    return KeyedSubtree(
      key: const Key('bank_accounts_list_sheet'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${AppStrings.bankAccounts} - $ownerName',
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton(
              key: const Key('add_bank_account_button'),
              label: AppStrings.addBankAccount,
              onPressed: () => BankAccountFormSheet.show(
                context,
                profileId: profileId,
                buyerId: buyerId,
                supplierId: supplierId,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Expanded(
              child: accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const Center(child: Text(AppStrings.noBankAccounts));
                  }

                  return ListView.separated(
                    itemCount: accounts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return Container(
                        key: Key('bank_account_item_${account.id}'),
                        decoration: BoxDecoration(
                          color: account.isArchived
                              ? theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        child: AppListRow(
                          title: account.name,
                          subtitle:
                              '${account.accountNumber}${account.notes != null && account.notes!.isNotEmpty ? '\n${account.notes}' : ''}${account.isArchived ? ' (${AppStrings.archived})' : ''}',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: Key('edit_bank_account_${account.id}'),
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => BankAccountFormSheet.show(
                                  context,
                                  bankAccount: account,
                                ),
                              ),
                              IconButton(
                                key: Key('archive_bank_account_${account.id}'),
                                icon: Icon(
                                  account.isArchived
                                      ? Icons.unarchive_outlined
                                      : Icons.archive_outlined,
                                ),
                                onPressed: () =>
                                    _handleArchiveToggle(context, ref, account),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (error, _) => Center(child: Text(error.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
