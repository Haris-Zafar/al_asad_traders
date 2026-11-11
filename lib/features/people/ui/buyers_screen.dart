import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/empty_state.dart';
import 'package:al_asad_traders/core/widgets/loading_view.dart';
import 'package:al_asad_traders/core/widgets/search_field.dart';
import 'package:al_asad_traders/features/people/providers/buyers_provider.dart';
import 'package:al_asad_traders/features/people/ui/buyer_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen listing buyers with search, filter, and add actions.
/// Rule: docs/UI_PLAN.md > Screens (/buyers). Story: S9.
class BuyersScreen extends ConsumerWidget {
  /// Creates a [BuyersScreen].
  const BuyersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredBuyersAsync = ref.watch(filteredBuyersProvider);
    final showArchived = ref.watch(buyersShowArchivedProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.buyersTab,
      scrollable: false,
      padding: EdgeInsets.zero,
      body: KeyedSubtree(
        key: const Key('buyers_screen'),
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
                          key: const Key('buyers_search_field'),
                          hintText: AppStrings.searchBuyers,
                          onChanged: (value) {
                            ref
                                .read(buyersSearchQueryProvider.notifier)
                                .setQuery(value);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      AppButton(
                        key: const Key('add_buyer_button'),
                        label: AppStrings.addBuyer,
                        icon: Icons.add,
                        width: 140,
                        onPressed: () {
                          BuyerFormSheet.show(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilterChip(
                        key: const Key('buyers_show_archived_chip'),
                        label: const Text(AppStrings.showHidden),
                        selected: showArchived,
                        onSelected: (selected) {
                          ref
                              .read(buyersShowArchivedProvider.notifier)
                              .toggle(selected);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredBuyersAsync.when(
                data: (buyers) {
                  if (buyers.isEmpty) {
                    return const EmptyState(
                      key: Key('buyers_empty_state'),
                      icon: Icons.people_outline,
                      message: AppStrings.noBuyersFound,
                    );
                  }
                  return ListView.builder(
                    itemCount: buyers.length,
                    itemBuilder: (context, index) {
                      final buyer = buyers[index];
                      final subtitleParts = <String>[];
                      if (buyer.contactNumber != null &&
                          buyer.contactNumber!.isNotEmpty) {
                        subtitleParts.add(buyer.contactNumber!);
                      }
                      if (buyer.address != null && buyer.address!.isNotEmpty) {
                        subtitleParts.add(buyer.address!);
                      }

                      return AppListRow(
                        key: Key('buyer_row_${buyer.id}'),
                        title: buyer.name,
                        subtitle: subtitleParts.isNotEmpty
                            ? subtitleParts.join(' • ')
                            : null,
                        trailing: buyer.isArchived
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
                          context.go('/buyers/${buyer.id}');
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
