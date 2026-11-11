import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
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

/// Filtered list of products based on search query and showArchived flag.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S1, S3, S4.
final Provider<AsyncValue<List<Product>>> filteredProductsProvider =
    Provider<AsyncValue<List<Product>>>((ref) {
      final productsAsync = ref.watch(productsStreamProvider);
      final query = ref.watch(productsSearchQueryProvider).trim().toLowerCase();
      final showArchived = ref.watch(productsShowArchivedProvider);

      return productsAsync.whenData((products) {
        return products.where((product) {
          if (!showArchived && product.isArchived) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          final nameMatches = product.name.toLowerCase().contains(query);
          final skuMatches =
              product.sku?.toLowerCase().contains(query) ?? false;
          final notesMatches =
              product.notes?.toLowerCase().contains(query) ?? false;
          return nameMatches || skuMatches || notesMatches;
        }).toList();
      });
    });
