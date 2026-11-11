import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/empty_state.dart';
import 'package:al_asad_traders/core/widgets/loading_view.dart';
import 'package:al_asad_traders/core/widgets/search_field.dart';
import 'package:al_asad_traders/features/people/providers/suppliers_provider.dart';
import 'package:al_asad_traders/features/people/ui/supplier_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen listing suppliers with search, filter, and add actions.
/// Rule: docs/UI_PLAN.md > Screens (/suppliers). Story: S9.
class SuppliersScreen extends ConsumerWidget {
  /// Creates a [SuppliersScreen].
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSuppliersAsync = ref.watch(filteredSuppliersProvider);
    final showArchived = ref.watch(suppliersShowArchivedProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.suppliersTitle,
      scrollable: false,
      padding: EdgeInsets.zero,
      body: KeyedSubtree(
        key: const Key('suppliers_screen'),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchField(
                          key: const Key('suppliers_search_field'),
                          hintText: AppStrings.searchSuppliers,
                          onChanged: (value) {
                            ref
                                .read(suppliersSearchQueryProvider.notifier)
                                .setQuery(value);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      AppButton(
                        key: const Key('add_supplier_button'),
                        label: AppStrings.addSupplier,
                        icon: Icons.add,
                        width: 140,
                        onPressed: () {
                          SupplierFormSheet.show(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilterChip(
                        key: const Key('suppliers_show_archived_chip'),
                        label: const Text(AppStrings.showHidden),
                        selected: showArchived,
                        onSelected: (selected) {
                          ref
                              .read(suppliersShowArchivedProvider.notifier)
                              .toggle(selected);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredSuppliersAsync.when(
                data: (suppliers) {
                  if (suppliers.isEmpty) {
                    return const EmptyState(
                      key: Key('suppliers_empty_state'),
                      icon: Icons.local_shipping_outlined,
                      message: AppStrings.noSuppliersFound,
                    );
                  }
                  return ListView.builder(
                    itemCount: suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];
                      final subtitleParts = <String>[];
                      if (supplier.contactNumber != null &&
                          supplier.contactNumber!.isNotEmpty) {
                        subtitleParts.add(supplier.contactNumber!);
                      }
                      if (supplier.address != null &&
                          supplier.address!.isNotEmpty) {
                        subtitleParts.add(supplier.address!);
                      }

                      return AppListRow(
                        key: Key('supplier_row_${supplier.id}'),
                        title: supplier.name,
                        subtitle: subtitleParts.isNotEmpty
                            ? subtitleParts.join(' • ')
                            : null,
                        trailing: supplier.isArchived
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
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
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/more/suppliers/${supplier.id}');
                        },
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
