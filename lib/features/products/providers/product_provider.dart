import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/data/tag_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:al_asad_traders/features/products/models/product_tag.dart';
import 'package:al_asad_traders/features/products/models/tag.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for watching all products.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1.
final StreamProvider<List<Product>> productsStreamProvider =
    StreamProvider<List<Product>>((ref) {
      final repository = ref.watch(productRepositoryProvider);
      return repository.watchProducts();
    });

/// Stream provider for a single product by ID.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1.
final productDetailStreamProvider = StreamProvider.autoDispose
    .family<Product?, String>((ref, id) {
      final repository = ref.watch(productRepositoryProvider);
      return repository.watchProducts().map((products) {
        try {
          return products.firstWhere((p) => p.id == id);
        } catch (_) {
          return null;
        }
      });
    });

/// Stream provider for watching all tags.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S3.
final StreamProvider<List<Tag>> tagsStreamProvider = StreamProvider<List<Tag>>((
  ref,
) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.watchTags();
});

/// Stream provider for watching all product-tag relations.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S3.
final StreamProvider<List<ProductTag>> productTagsStreamProvider =
    StreamProvider<List<ProductTag>>((ref) {
      final repository = ref.watch(tagRepositoryProvider);
      return repository.watchProductTags();
    });

/// Stream provider for tag IDs associated with a specific product.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S3.
final productTagsForProductProvider = StreamProvider.autoDispose
    .family<List<String>, String>((ref, productId) {
      final repository = ref.watch(tagRepositoryProvider);
      return repository.watchTagsForProduct(productId);
    });

/// Notifier for search query string filtering products.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1.
class ProductsSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// Updates the search query string.
  void setQuery(String query) => state = query;
}

/// Search query string provider for filtering products.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1.
final productsSearchQueryProvider =
    NotifierProvider<ProductsSearchQueryNotifier, String>(
      ProductsSearchQueryNotifier.new,
    );

/// Notifier for toggling showing hidden/archived products.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1, S4.
class ProductsShowArchivedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Toggles whether archived products are displayed.
  void toggle(bool show) => state = show;
}

/// Toggle provider for showing hidden/archived products.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1, S4.
final productsShowArchivedProvider =
    NotifierProvider<ProductsShowArchivedNotifier, bool>(
      ProductsShowArchivedNotifier.new,
    );

/// Notifier for selecting a tag ID to filter products.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S3.
class SelectedTagIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Sets the selected tag ID filter (null for all tags).
  void selectTag(String? tagId) => state = tagId;
}

/// Provider for selected tag ID filter.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S3.
final selectedTagIdProvider = NotifierProvider<SelectedTagIdNotifier, String?>(
  SelectedTagIdNotifier.new,
);

/// Filtered list of products based on search query, showArchived flag, and selected tag ID.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1, S3, S4.
final Provider<AsyncValue<List<Product>>>
filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  final productTagsAsync = ref.watch(productTagsStreamProvider);
  final query = ref.watch(productsSearchQueryProvider).trim().toLowerCase();
  final showArchived = ref.watch(productsShowArchivedProvider);
  final selectedTagId = ref.watch(selectedTagIdProvider);

  if (productsAsync is AsyncError) {
    return AsyncValue.error(productsAsync.error!, productsAsync.stackTrace!);
  }
  if (productTagsAsync is AsyncError) {
    return AsyncValue.error(
      productTagsAsync.error!,
      productTagsAsync.stackTrace!,
    );
  }

  if (productsAsync.isLoading || productTagsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final products = productsAsync.value ?? [];
  final productTags = productTagsAsync.value ?? [];

  final taggedProductIds = selectedTagId != null && selectedTagId.isNotEmpty
      ? productTags
            .where((pt) => pt.tagId == selectedTagId)
            .map((pt) => pt.productId)
            .toSet()
      : null;

  final filtered = products.where((product) {
    if (!showArchived && product.isArchived) {
      return false;
    }
    if (taggedProductIds != null && !taggedProductIds.contains(product.id)) {
      return false;
    }
    if (query.isEmpty) {
      return true;
    }
    final nameMatches = product.name.toLowerCase().contains(query);
    final skuMatches = product.sku?.toLowerCase().contains(query) ?? false;
    final notesMatches = product.notes?.toLowerCase().contains(query) ?? false;
    return nameMatches || skuMatches || notesMatches;
  }).toList();

  return AsyncValue.data(filtered);
});
