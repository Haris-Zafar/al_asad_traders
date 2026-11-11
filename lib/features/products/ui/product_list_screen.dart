import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/empty_state.dart';
import 'package:al_asad_traders/core/widgets/search_field.dart';
import 'package:al_asad_traders/features/products/providers/product_provider.dart';
import 'package:al_asad_traders/features/products/ui/product_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen listing products with search, tag filter, and add actions.
/// Rule: docs/UI_PLAN.md > Screens (/products). Story: S1, S3, S4.
class ProductListScreen extends ConsumerWidget {
  /// Creates a [ProductListScreen].
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final showArchived = ref.watch(productsShowArchivedProvider);
    final tagsAsync = ref.watch(tagsStreamProvider);
    final selectedTagId = ref.watch(selectedTagIdProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.productsTitle,
      scrollable: false,
      padding: EdgeInsets.zero,
      body: KeyedSubtree(
        key: const Key('products_screen'),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchField(
                          key: const Key('products_search_field'),
                          hintText: AppStrings.searchProducts,
                          onChanged: (value) {
                            ref
                                .read(productsSearchQueryProvider.notifier)
                                .setQuery(value);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      AppButton(
                        key: const Key('products_scan_button'),
                        label: AppStrings.scan,
                        icon: Icons.qr_code_scanner,
                        width: 100,
                        onPressed: () {
                          context.push('/scan');
                        },
                      ),
                      const SizedBox(width: AppSpacing.s),
                      AppButton(
                        key: const Key('add_product_button'),
                        label: AppStrings.addProduct,
                        icon: Icons.add,
                        width: 130,
                        onPressed: () {
                          ProductFormSheet.show(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          key: const Key('tag_chip_all'),
                          label: const Text(AppStrings.allTags),
                          selected: selectedTagId == null,
                          onSelected: (_) {
                            ref
                                .read(selectedTagIdProvider.notifier)
                                .selectTag(null);
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        ...tagsAsync.when(
                          data: (tags) => tags.map((tag) {
                            final isSelected = selectedTagId == tag.id;
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.xs,
                              ),
                              child: FilterChip(
                                key: Key('tag_chip_${tag.id}'),
                                label: Text(tag.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  ref
                                      .read(selectedTagIdProvider.notifier)
                                      .selectTag(selected ? tag.id : null);
                                },
                              ),
                            );
                          }),
                          loading: () => const [],
                          error: (_, _) => const [],
                        ),
                        FilterChip(
                          key: const Key('products_show_archived_chip'),
                          label: const Text(AppStrings.showHidden),
                          selected: showArchived,
                          onSelected: (selected) {
                            ref
                                .read(productsShowArchivedProvider.notifier)
                                .toggle(selected);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredProductsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const EmptyState(
                      key: Key('products_empty_state'),
                      icon: Icons.inventory_2_outlined,
                      message: AppStrings.noProductsFound,
                    );
                  }
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final subtitleParts = <String>[];
                      if (product.sku != null && product.sku!.isNotEmpty) {
                        subtitleParts.add('Barcode: ${product.sku}');
                      }
                      subtitleParts.add(
                        'Shop price: Rs ${product.defaultRetailPrice}',
                      );

                      return AppListRow(
                        key: Key('product_row_${product.id}'),
                        title: product.name,
                        subtitle: subtitleParts.join(' • '),
                        trailing: product.isArchived
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
                            : null,
                        onTap: () {
                          context.go('/more/products/${product.id}');
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
