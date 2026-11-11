import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/action_row.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_dialogs.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/loading_view.dart';
import 'package:al_asad_traders/features/people/data/suppliers_repository.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:al_asad_traders/features/people/providers/suppliers_provider.dart';
import 'package:al_asad_traders/features/people/ui/supplier_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen displaying details of a specific supplier.
/// Rule: docs/UI_PLAN.md > Screens (/suppliers/:id). Story: S9.
class SupplierDetailScreen extends ConsumerWidget {
  /// Creates a [SupplierDetailScreen].
  const SupplierDetailScreen({super.key, required this.supplierId});

  /// ID of the supplier to display.
  final String supplierId;

  Future<void> _handleArchiveToggle(
    BuildContext context,
    WidgetRef ref,
    Supplier supplier,
  ) async {
    final repository = ref.read(suppliersRepositoryProvider);
    if (supplier.isArchived) {
      await repository.unarchiveSupplier(supplier.id);
    } else {
      final warnings = await repository.checkArchiveWarnings(supplier.id);
      if (!context.mounted) return;

      final message = warnings.isNotEmpty
          ? '${AppStrings.archiveSupplierWarning}\n\n• ${warnings.join('\n• ')}'
          : AppStrings.archiveSupplierWarning;

      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.archiveSupplierTitle,
        message: message,
        confirmLabel: AppStrings.confirmHide,
        isDanger: true,
      );

      if (confirmed == true) {
        await repository.archiveSupplier(supplier.id);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(supplierDetailStreamProvider(supplierId));
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.supplierDetails,
      body: supplierAsync.when(
        data: (supplier) {
          if (supplier == null) {
            return const Center(child: Text(AppStrings.noSuppliersFound));
          }

          return KeyedSubtree(
            key: const Key('supplier_detail_screen'),
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
                          supplier.name,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      if (supplier.isArchived)
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
                  if (supplier.contactNumber != null &&
                      supplier.contactNumber!.isNotEmpty)
                    AppListRow(
                      key: const Key('supplier_contact_row'),
                      title: AppStrings.contactNumberLabel,
                      subtitle: supplier.contactNumber,
                    ),
                  if (supplier.address != null && supplier.address!.isNotEmpty)
                    AppListRow(
                      key: const Key('supplier_address_row'),
                      title: AppStrings.addressLabel,
                      subtitle: supplier.address,
                    ),
                  if (supplier.notes != null && supplier.notes!.isNotEmpty)
                    AppListRow(
                      key: const Key('supplier_notes_row'),
                      title: AppStrings.notesLabel,
                      subtitle: supplier.notes,
                    ),
                  const SizedBox(height: AppSpacing.l),
                  AppListRow(
                    key: const Key('supplier_bank_accounts_row'),
                    title: AppStrings.bankAccounts,
                    subtitle: 'View saved bank accounts',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ActionRow(
                    primary: AppButton(
                      key: const Key('edit_supplier_button'),
                      label: AppStrings.editSupplier,
                      onPressed: () =>
                          SupplierFormSheet.show(context, supplier: supplier),
                    ),
                    secondary: AppButton(
                      key: const Key('supplier_archive_button'),
                      label: supplier.isArchived
                          ? AppStrings.unhide
                          : AppStrings.hide,
                      variant: supplier.isArchived
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.danger,
                      onPressed: () =>
                          _handleArchiveToggle(context, ref, supplier),
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
