import 'package:al_asad_traders/features/people/data/buyers_repository.dart';
import 'package:al_asad_traders/features/people/models/buyer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for watching all buyers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final StreamProvider<List<Buyer>> buyersStreamProvider =
    StreamProvider<List<Buyer>>((ref) {
      final repository = ref.watch(buyersRepositoryProvider);
      return repository.watchBuyers();
    });

/// Stream provider for a single buyer by ID.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final buyerDetailStreamProvider = StreamProvider.autoDispose
    .family<Buyer?, String>((ref, id) {
      final repository = ref.watch(buyersRepositoryProvider);
      return repository.watchBuyers().map((buyers) {
        try {
          return buyers.firstWhere((b) => b.id == id);
        } catch (_) {
          return null;
        }
      });
    });

/// Notifier for search query string filtering buyers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
class BuyersSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// Updates the search query string.
  void setQuery(String query) => state = query;
}

/// Search query string provider for filtering buyers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final buyersSearchQueryProvider =
    NotifierProvider<BuyersSearchQueryNotifier, String>(
      BuyersSearchQueryNotifier.new,
    );

/// Notifier for toggling showing hidden/archived buyers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
class BuyersShowArchivedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Toggles whether archived buyers are displayed.
  void toggle(bool show) => state = show;
}

/// Toggle provider for showing hidden/archived buyers.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final buyersShowArchivedProvider =
    NotifierProvider<BuyersShowArchivedNotifier, bool>(
      BuyersShowArchivedNotifier.new,
    );

/// Filtered list of buyers based on search query and showArchived flag.
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S9.
final Provider<AsyncValue<List<Buyer>>> filteredBuyersProvider =
    Provider<AsyncValue<List<Buyer>>>((ref) {
      final buyersAsync = ref.watch(buyersStreamProvider);
      final query = ref.watch(buyersSearchQueryProvider).trim().toLowerCase();
      final showArchived = ref.watch(buyersShowArchivedProvider);

      return buyersAsync.whenData((buyers) {
        return buyers.where((buyer) {
          if (!showArchived && buyer.isArchived) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          final nameMatches = buyer.name.toLowerCase().contains(query);
          final phoneMatches =
              buyer.contactNumber?.toLowerCase().contains(query) ?? false;
          final addressMatches =
              buyer.address?.toLowerCase().contains(query) ?? false;
          return nameMatches || phoneMatches || addressMatches;
        }).toList();
      });
    });
