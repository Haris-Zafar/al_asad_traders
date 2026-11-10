import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Layout row presenting two action buttons side-by-side on wide screens/normal text,
/// and stacking them vertically when narrow or at text scales above 1.3.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class ActionRow extends StatelessWidget {
  /// Creates an [ActionRow].
  const ActionRow({super.key, required this.primary, required this.secondary});

  /// Primary action widget (usually [AppButton] with primary or danger variant).
  final Widget primary;

  /// Secondary action widget (usually [AppButton] with secondary variant).
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool shouldStack = textScale > 1.3 || constraints.maxWidth < 280;

        if (shouldStack) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              const SizedBox(height: AppSpacing.s),
              secondary,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: secondary),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: primary),
          ],
        );
      },
    );
  }
}
