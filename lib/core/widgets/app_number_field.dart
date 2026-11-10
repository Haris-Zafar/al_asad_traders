import 'package:al_asad_traders/core/format/money_format.dart';
import 'package:al_asad_traders/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formatter that automatically adds thousands commas to whole numbers as typed.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final String clean = newValue.text.replaceAll(',', '');
    final int? number = int.tryParse(clean);
    if (number == null) {
      return oldValue;
    }
    final String formatted = MoneyFormat.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Whole-number input field with number pad and thousands separators.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class AppNumberField extends StatefulWidget {
  /// Creates an [AppNumberField].
  const AppNumberField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
  });

  /// The label displayed permanently above the input box.
  final String label;

  /// Initial whole number value.
  final int? initialValue;

  /// Optional placeholder hint text.
  final String? hintText;

  /// Optional error message displayed underneath the input box.
  final String? errorText;

  /// Optional external text controller.
  final TextEditingController? controller;

  /// Callback fired with the parsed integer value when changed.
  final ValueChanged<int?>? onChanged;

  /// Callback fired with the parsed integer value when submitted.
  final ValueChanged<int?>? onSubmitted;

  /// Whether editing is disabled.
  final bool readOnly;

  /// Whether this field requests focus on appearance.
  final bool autofocus;

  /// Optional leading widget inside the field boundary.
  final Widget? prefixIcon;

  /// Optional trailing widget inside the field boundary.
  final Widget? suffixIcon;

  /// Optional explicit focus node.
  final FocusNode? focusNode;

  @override
  State<AppNumberField> createState() => _AppNumberFieldState();
}

class _AppNumberFieldState extends State<AppNumberField> {
  late TextEditingController _controller;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _internalController = true;
      final String initialText = widget.initialValue != null
          ? MoneyFormat.format(widget.initialValue!)
          : '';
      _controller = TextEditingController(text: initialText);
    }
  }

  @override
  void didUpdateWidget(covariant AppNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_internalController) {
        _controller.dispose();
        _internalController = false;
      }
      _controller = widget.controller!;
    } else if (widget.initialValue != oldWidget.initialValue &&
        _internalController) {
      final String newText = widget.initialValue != null
          ? MoneyFormat.format(widget.initialValue!)
          : '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      errorText: widget.errorText,
      controller: _controller,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      focusNode: widget.focusNode,
      keyboardType: const TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
        ThousandsSeparatorInputFormatter(),
      ],
      onChanged: (String text) {
        final int? value = MoneyFormat.parse(text);
        widget.onChanged?.call(value);
      },
      onSubmitted: (String text) {
        final int? value = MoneyFormat.parse(text);
        widget.onSubmitted?.call(value);
      },
    );
  }
}
