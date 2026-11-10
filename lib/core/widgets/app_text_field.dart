import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard form text input field with label always above and error below.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class AppTextField extends StatelessWidget {
  /// Creates an [AppTextField].
  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.focusNode,
  });

  /// The label displayed permanently above the input box.
  final String label;

  /// Optional placeholder hint text.
  final String? hintText;

  /// Optional error message displayed underneath the input box.
  final String? errorText;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when submitted via keyboard action.
  final ValueChanged<String>? onSubmitted;

  /// Virtual keyboard input type.
  final TextInputType? keyboardType;

  /// Input formatters to constrain entered characters.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether editing is disabled while keeping selectable text.
  final bool readOnly;

  /// Whether this field requests focus on appearance.
  final bool autofocus;

  /// Optional leading widget inside the field boundary.
  final Widget? prefixIcon;

  /// Optional trailing widget inside the field boundary.
  final Widget? suffixIcon;

  /// Maximum line count. Defaults to 1.
  final int maxLines;

  /// Optional explicit focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
