import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Search input field designed for pickers and searchable lists.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class SearchField extends StatefulWidget {
  /// Creates a [SearchField].
  const SearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  /// Placeholder hint text indicating what can be searched.
  final String hintText;

  /// Optional text editing controller.
  final TextEditingController? controller;

  /// Callback when query changes.
  final ValueChanged<String>? onChanged;

  /// Callback when search field is cleared.
  final VoidCallback? onClear;

  /// Whether this field receives autofocus.
  final bool autofocus;

  /// Optional focus node.
  final FocusNode? focusNode;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _internalController = true;
      _controller = TextEditingController();
    }
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _controller.text.isNotEmpty;

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search, size: AppSizes.iconSize),
        suffixIcon: hasText
            ? IconButton(
                icon: const Icon(Icons.clear, size: AppSizes.iconSize),
                tooltip: AppStrings.cancel,
                onPressed: _handleClear,
              )
            : null,
      ),
      onChanged: widget.onChanged,
    );
  }
}
