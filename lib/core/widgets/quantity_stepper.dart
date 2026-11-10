import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_number_field.dart';
import 'package:flutter/material.dart';

/// Quantity stepper with decrement, direct-edit tap, and increment controls.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class QuantityStepper extends StatelessWidget {
  /// Creates a [QuantityStepper].
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 0,
    this.max = 999999,
  });

  /// Current whole-number quantity.
  final int quantity;

  /// Callback when quantity changes.
  final ValueChanged<int> onChanged;

  /// Minimum allowable quantity.
  final int min;

  /// Maximum allowable quantity.
  final int max;

  Future<void> _showEditDialog(BuildContext context) async {
    final TextEditingController textController = TextEditingController(
      text: quantity.toString(),
    );

    final int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.item),
          content: AppNumberField(
            label: AppStrings.item,
            controller: textController,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.cancel),
            ),
            AppButton(
              label: AppStrings.ok,
              width: AppSizes.touchTarget * 2,
              onPressed: () {
                final int? parsed = int.tryParse(
                  textController.text.replaceAll(',', ''),
                );
                Navigator.of(dialogContext).pop(parsed);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result >= min && result <= max) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canDecrease = quantity > min;
    final bool canIncrease = quantity < max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppSizes.touchTarget,
          height: AppSizes.touchTarget,
          child: IconButton(
            icon: const Icon(Icons.remove, size: AppSizes.iconSize),
            tooltip: AppStrings.decrease,
            onPressed: canDecrease ? () => onChanged(quantity - 1) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        InkWell(
          onTap: () => _showEditDialog(context),
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppSizes.touchTarget,
              minHeight: AppSizes.touchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.s,
                right: AppSpacing.s,
                top: AppSpacing.s,
                bottom: AppSpacing.s,
              ),
              child: Center(
                child: Text(
                  quantity.toString(),
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        SizedBox(
          width: AppSizes.touchTarget,
          height: AppSizes.touchTarget,
          child: IconButton(
            icon: const Icon(Icons.add, size: AppSizes.iconSize),
            tooltip: AppStrings.increase,
            onPressed: canIncrease ? () => onChanged(quantity + 1) : null,
          ),
        ),
      ],
    );
  }
}
