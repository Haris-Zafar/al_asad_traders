import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/action_row.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_dialogs.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/loading_view.dart';
import 'package:al_asad_traders/features/people/data/buyers_repository.dart';
import 'package:al_asad_traders/features/people/models/buyer.dart';
import 'package:al_asad_traders/features/people/providers/buyers_provider.dart';
import 'package:al_asad_traders/features/people/ui/buyer_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying details of a specific buyer.
/// Rule: docs/UI_PLAN.md > Screens (/buyers/:id). Story: S9.
class BuyerDetailScreen extends ConsumerWidget {
  /// Creates a [BuyerDetailScreen].
  const BuyerDetailScreen({super.key, required this.buyerId});

  /// ID of the buyer to display.
  final String buyerId;

  Future<void> _handleArchiveToggle(
    BuildContext context,
    WidgetRef ref,
    Buyer buyer,
  ) async {
    final repository = ref.read(buyersRepositoryProvider);
    if (buyer.isArchived) {
      await repository.unarchiveBuyer(buyer.id);
    } else {
      final warnings = await repository.checkArchiveWarnings(buyer.id);
      if (!context.mounted) return;

      final message = warnings.isNotEmpty
          ? '${AppStrings.archiveBuyerWarning}\n\n• ${warnings.join('\n• ')}'
          : AppStrings.archiveBuyerWarning;

      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.archiveBuyerTitle,
        message: message,
        confirmLabel: AppStrings.confirmHide,
        isDanger: true,
      );

      if (confirmed == true) {
        await repository.archiveBuyer(buyer.id);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buyerAsync = ref.watch(buyerDetailStreamProvider(buyerId));
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.buyerDetails,
      body: buyerAsync.when(
        data: (buyer) {
          if (buyer == null) {
            return const Center(child: Text(AppStrings.noBuyersFound));
          }

          return KeyedSubtree(
            key: const Key('buyer_detail_screen'),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          buyer.name,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      if (buyer.isArchived)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius,
                            ),
                          ),
                          child: Text(
                            AppStrings.archived,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (buyer.contactNumber != null &&
                      buyer.contactNumber!.isNotEmpty)
                    AppListRow(
                      key: const Key('buyer_contact_row'),
                      title: AppStrings.contactNumberLabel,
                      subtitle: buyer.contactNumber,
                    ),
                  if (buyer.address != null && buyer.address!.isNotEmpty)
                    AppListRow(
                      key: const Key('buyer_address_row'),
                      title: AppStrings.addressLabel,
                      subtitle: buyer.address,
                    ),
                  if (buyer.notes != null && buyer.notes!.isNotEmpty)
                    AppListRow(
                      key: const Key('buyer_notes_row'),
                      title: AppStrings.notesLabel,
                      subtitle: buyer.notes,
                    ),
                  const SizedBox(height: AppSpacing.l),
                  AppListRow(
                    key: const Key('buyer_account_row'),
                    title: AppStrings.accountBalance,
                    subtitle: 'View ledger entries',
                    onTap: () => context.go('/buyers/${buyer.id}/account'),
                  ),
                  AppListRow(
                    key: const Key('buyer_bank_accounts_row'),
                    title: AppStrings.bankAccounts,
                    subtitle: 'View saved bank accounts',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ActionRow(
                    primary: AppButton(
                      key: const Key('edit_buyer_button'),
                      label: AppStrings.editBuyer,
                      onPressed: () =>
                          BuyerFormSheet.show(context, buyer: buyer),
                    ),
                    secondary: AppButton(
                      key: const Key('buyer_archive_button'),
                      label: buyer.isArchived
                          ? AppStrings.unhide
                          : AppStrings.hide,
                      variant: buyer.isArchived
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.danger,
                      onPressed: () =>
                          _handleArchiveToggle(context, ref, buyer),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
