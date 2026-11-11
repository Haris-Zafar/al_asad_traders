import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/action_row.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_dialogs.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:al_asad_traders/features/products/providers/product_provider.dart';
import 'package:al_asad_traders/features/products/ui/product_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen displaying details of a specific product.
/// Rule: docs/UI_PLAN.md > Screens (/products/:id). Story: S1, S3, S4.
class ProductDetailScreen extends ConsumerWidget {
  /// Creates a [ProductDetailScreen].
  const ProductDetailScreen({super.key, required this.productId});

  /// ID of the product to display.
  final String productId;

  Future<void> _handleArchiveToggle(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final repository = ref.read(productRepositoryProvider);
    if (product.isArchived) {
      final updated = product.copyWith(archivedAt: null);
      await repository.saveProduct(updated);
    } else {
      final warnings = await repository.checkArchiveWarnings(product.id);
      if (!context.mounted) return;

      final message = warnings.isNotEmpty
          ? '${AppStrings.archiveProductWarning}\n\n• ${warnings.join('\n• ')}'
          : AppStrings.archiveProductWarning;

      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.archiveProductTitle,
        message: message,
        confirmLabel: AppStrings.confirmHide,
        isDanger: true,
      );

      if (confirmed == true) {
        final updated = product.copyWith(archivedAt: DateTime.now());
        await repository.saveProduct(updated);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailStreamProvider(productId));
    final productTagsAsync = ref.watch(
      productTagsForProductProvider(productId),
    );
    final tagsAsync = ref.watch(tagsStreamProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.productDetails,
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text(AppStrings.noProductsFound));
          }

          final tagIds = productTagsAsync.value ?? [];
          final allTags = tagsAsync.value ?? [];
          final assignedTags = allTags
              .where((t) => tagIds.contains(t.id))
              .toList();

          return KeyedSubtree(
            key: const Key('product_detail_screen'),
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
                          product.name,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      if (product.isArchived)
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
                  if (assignedTags.isNotEmpty) ...[
                    Text(
                      AppStrings.tagsLabel,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: assignedTags
                          .map(
                            (tag) => Chip(
                              key: Key('product_detail_tag_${tag.id}'),
                              label: Text(tag.name),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  if (product.sku != null && product.sku!.isNotEmpty)
                    AppListRow(
                      key: const Key('product_sku_row'),
                      title: AppStrings.barcode,
                      subtitle: product.sku,
                    ),
                  AppListRow(
                    key: const Key('product_supplier_rate_row'),
                    title: AppStrings.defaultBuyingPrice,
                    subtitle: 'Rs ${product.defaultSupplierRate}',
                  ),
                  AppListRow(
                    key: const Key('product_buyer_rate_row'),
                    title: AppStrings.defaultSellingPrice,
                    subtitle: 'Rs ${product.defaultBuyerRate}',
                  ),
                  AppListRow(
                    key: const Key('product_retail_price_row'),
                    title: AppStrings.shopPriceLabel,
                    subtitle: 'Rs ${product.defaultRetailPrice}',
                  ),
                  if (product.notes != null && product.notes!.isNotEmpty)
                    AppListRow(
                      key: const Key('product_notes_row'),
                      title: AppStrings.notesLabel,
                      subtitle: product.notes,
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  ActionRow(
                    primary: AppButton(
                      key: const Key('edit_product_button'),
                      label: AppStrings.editProduct,
                      onPressed: () =>
                          ProductFormSheet.show(context, product: product),
                    ),
                    secondary: AppButton(
                      key: const Key('product_archive_button'),
                      label: product.isArchived
                          ? AppStrings.unhide
                          : AppStrings.hide,
                      variant: product.isArchived
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.danger,
                      onPressed: () =>
                          _handleArchiveToggle(context, ref, product),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
