import 'package:al_asad_traders/core/theme/app_colors.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/theme/app_text.dart';
import 'package:al_asad_traders/core/theme/app_theme.dart';
import 'package:al_asad_traders/core/theme/status_colors.dart';
import 'package:al_asad_traders/core/theme/text_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme and Tokens', () {
    test('buildTheme returns light Material3 ThemeData with tokens', () {
      final theme = buildTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.background);

      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.accent);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.colorScheme.outline, AppColors.border);

      final statusColors = theme.extension<StatusColors>();
      expect(statusColors, isNotNull);
      expect(statusColors!.chipDraftBackground, AppColors.chipDraftBackground);
      expect(statusColors.chipDraftText, AppColors.chipDraftText);
      expect(
        statusColors.chipFinishedBackground,
        AppColors.chipFinishedBackground,
      );
      expect(statusColors.chipFinishedText, AppColors.chipFinishedText);
      expect(statusColors.chipPaidBackground, AppColors.chipPaidBackground);
      expect(statusColors.chipPaidText, AppColors.chipPaidText);
      expect(
        statusColors.chipOnAccountBackground,
        AppColors.chipOnAccountBackground,
      );
      expect(statusColors.chipOnAccountText, AppColors.chipOnAccountText);
      expect(statusColors.success, AppColors.success);
    });

    test('AppSizes and AppSpacing tokens match design system spec', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.s, 8.0);
      expect(AppSpacing.m, 16.0);
      expect(AppSpacing.l, 24.0);
      expect(AppSpacing.xl, 32.0);

      expect(AppSizes.touchTarget, 56.0);
      expect(AppSizes.buttonHeight, 56.0);
      expect(AppSizes.iconSize, 28.0);
      expect(AppSizes.radius, 12.0);
      expect(AppSizes.borderWidth, 1.5);
      expect(AppSizes.focusWidth, 3.0);
      expect(AppSizes.maxContentWidth, 600.0);
    });

    test('buildTextTheme scales font sizes appropriately', () {
      final textTheme1 = buildTextTheme(1.0);
      expect(textTheme1.amount.fontSize, 28.0);
      expect(textTheme1.title.fontSize, 24.0);
      expect(textTheme1.section.fontSize, 20.0);
      expect(textTheme1.body.fontSize, 18.0);
      expect(textTheme1.bodyStrong.fontSize, 18.0);
      expect(textTheme1.caption.fontSize, 16.0);

      final textTheme12 = buildTextTheme(1.2);
      expect(textTheme12.amount.fontSize, 28.0 * 1.2);
      expect(textTheme12.caption.fontSize, 16.0 * 1.2);
    });

    test('TextScaleChoice calculates effective scale clamped to 2.0', () {
      expect(
        TextScaleChoice.calculateEffectiveScale(
          userFactor: TextScaleChoice.normal.factor,
          phoneScale: 1.0,
        ),
        1.0,
      );
      expect(
        TextScaleChoice.calculateEffectiveScale(
          userFactor: TextScaleChoice.extraLarge.factor,
          phoneScale: 1.8,
        ),
        2.0, // 1.4 * 1.8 = 2.52 clamped to 2.0
      );
      expect(
        TextScaleChoice.calculateEffectiveScale(
          userFactor: TextScaleChoice.normal.factor,
          phoneScale: 0.8,
        ),
        1.0, // clamped to minimum 1.0
      );
    });

    test('StatusColors copyWith and lerp operate properly', () {
      final base = StatusColors.light();
      final copied = base.copyWith(success: AppColors.primary);
      expect(copied.success, AppColors.primary);
      expect(copied.chipDraftText, base.chipDraftText);

      final lerped = base.lerp(copied, 0.5);
      expect(lerped.success, Color.lerp(base.success, AppColors.primary, 0.5));
    });
  });
}
