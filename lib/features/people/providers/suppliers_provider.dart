import 'package:al_asad_traders/features/people/data/suppliers_repository.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for watching all suppliers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final StreamProvider<List<Supplier>> suppliersStreamProvider =
    StreamProvider<List<Supplier>>((ref) {
      final repository = ref.watch(suppliersRepositoryProvider);
      return repository.watchSuppliers();
    });

/// Stream provider for a single supplier by ID.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final supplierDetailStreamProvider = StreamProvider.autoDispose
    .family<Supplier?, String>((ref, id) {
      final repository = ref.watch(suppliersRepositoryProvider);
      return repository.watchSuppliers().map((suppliers) {
        try {
          return suppliers.firstWhere((s) => s.id == id);
        } catch (_) {
          return null;
        }
      });
    });

/// Notifier for search query string filtering suppliers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
class SuppliersSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// Updates the search query string.
  void setQuery(String query) => state = query;
}

/// Search query string provider for filtering suppliers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final suppliersSearchQueryProvider =
    NotifierProvider<SuppliersSearchQueryNotifier, String>(
      SuppliersSearchQueryNotifier.new,
    );

/// Notifier for toggling showing hidden/archived suppliers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
class SuppliersShowArchivedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Toggles whether archived suppliers are displayed.
  void toggle(bool show) => state = show;
}

/// Toggle provider for showing hidden/archived suppliers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final suppliersShowArchivedProvider =
    NotifierProvider<SuppliersShowArchivedNotifier, bool>(
      SuppliersShowArchivedNotifier.new,
    );

/// Filtered list of suppliers based on search query and showArchived flag.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final Provider<AsyncValue<List<Supplier>>> filteredSuppliersProvider =
    Provider<AsyncValue<List<Supplier>>>((ref) {
      final suppliersAsync = ref.watch(suppliersStreamProvider);
      final query = ref
          .watch(suppliersSearchQueryProvider)
          .trim()
          .toLowerCase();
      final showArchived = ref.watch(suppliersShowArchivedProvider);

      return suppliersAsync.whenData((suppliers) {
        return suppliers.where((supplier) {
          if (!showArchived && supplier.isArchived) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          final nameMatches = supplier.name.toLowerCase().contains(query);
          final phoneMatches =
              supplier.contactNumber?.toLowerCase().contains(query) ?? false;
          final addressMatches =
              supplier.address?.toLowerCase().contains(query) ?? false;
          return nameMatches || phoneMatches || addressMatches;
        }).toList();
      });
    });
