import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/theme/status_colors.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Error panel displaying an error message with an optional retry action.
/// Rule: docs/UI_PLAN.md > Loading, empty and error states. Story: none.
class ErrorPanel extends StatelessWidget {
  /// Creates an [ErrorPanel].
  const ErrorPanel({super.key, this.message, this.onRetry});

  /// Plain error explanation sentence. Defaults to [AppStrings.errorCouldNotLoad].
  final String? message;

  /// Optional callback to retry the failed operation.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final StatusColors? statusColors = theme.extension<StatusColors>();

    final Color containerColor =
        statusColors?.errorContainer ?? colors.errorContainer;
    final Color onContainerColor =
        statusColors?.onErrorContainer ?? colors.onErrorContainer;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.m,
          right: AppSpacing.m,
          top: AppSpacing.m,
          bottom: AppSpacing.m,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: onContainerColor,
              width: AppSizes.borderWidth,
            ),
          ),
          padding: const EdgeInsets.only(
            left: AppSpacing.m,
            right: AppSpacing.m,
            top: AppSpacing.m,
            bottom: AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: AppSizes.iconSize * 1.5,
                color: onContainerColor,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                message ?? AppStrings.errorCouldNotLoad,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onContainerColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.m),
                AppButton(
                  label: AppStrings.tryAgain,
                  variant: AppButtonVariant.secondary,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
