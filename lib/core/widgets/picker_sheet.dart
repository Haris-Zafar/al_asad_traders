import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_sheet.dart';
import 'package:al_asad_traders/core/widgets/search_field.dart';
import 'package:flutter/material.dart';

/// Searchable picker sheet to select an entity such as a buyer, product, or supplier.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class PickerSheet<T> extends StatefulWidget {
  /// Creates a [PickerSheet].
  const PickerSheet({
    super.key,
    required this.title,
    required this.searchHint,
    required this.items,
    required this.itemTitle,
    required this.onSelected,
    this.itemSubtitle,
    this.itemTrailing,
    this.itemFilter,
    this.emptyMessage,
  });

  /// Sheet header title.
  final String title;

  /// Placeholder hint for search box.
  final String searchHint;

  /// Full list of items to select from.
  final List<T> items;

  /// Converts an item to primary title text.
  final String Function(T item) itemTitle;

  /// Converts an item to secondary subtitle text.
  final String? Function(T item)? itemSubtitle;

  /// Converts an item to trailing widget.
  final Widget? Function(T item)? itemTrailing;

  /// Custom search filter matching item against user query.
  final bool Function(T item, String query)? itemFilter;

  /// Selection callback.
  final ValueChanged<T> onSelected;

  /// Message displayed when search has no matching items.
  final String? emptyMessage;

  /// Convenience helper to open this picker sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String searchHint,
    required List<T> items,
    required String Function(T item) itemTitle,
    String? Function(T item)? itemSubtitle,
    Widget? Function(T item)? itemTrailing,
    bool Function(T item, String query)? itemFilter,
    String? emptyMessage,
  }) {
    return AppSheet.show<T>(
      context,
      title: title,
      child: PickerSheet<T>(
        title: title,
        searchHint: searchHint,
        items: items,
        itemTitle: itemTitle,
        itemSubtitle: itemSubtitle,
        itemTrailing: itemTrailing,
        itemFilter: itemFilter,
        emptyMessage: emptyMessage,
        onSelected: (T selected) => Navigator.of(context).pop(selected),
      ),
    );
  }

  @override
  State<PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<PickerSheet<T>> {
  String _query = '';

  List<T> get _filteredItems {
    if (_query.trim().isEmpty) {
      return widget.items;
    }
    final String q = _query.trim().toLowerCase();
    return widget.items.where((T item) {
      if (widget.itemFilter != null) {
        return widget.itemFilter!(item, q);
      }
      final String title = widget.itemTitle(item).toLowerCase();
      final String subtitle =
          widget.itemSubtitle?.call(item)?.toLowerCase() ?? '';
      return title.contains(q) || subtitle.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<T> items = _filteredItems;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchField(
          hintText: widget.searchHint,
          onChanged: (String text) => setState(() => _query = text),
          autofocus: false,
        ),
        const SizedBox(height: AppSpacing.s),
        Flexible(
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.m,
                    right: AppSpacing.m,
                    top: AppSpacing.l,
                    bottom: AppSpacing.l,
                  ),
                  child: Center(
                    child: Text(
                      widget.emptyMessage ?? widget.searchHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final T item = items[index];
                    return AppListRow(
                      title: widget.itemTitle(item),
                      subtitle: widget.itemSubtitle?.call(item),
                      trailing: widget.itemTrailing?.call(item),
                      onTap: () => widget.onSelected(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
