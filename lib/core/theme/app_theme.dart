import 'package:al_asad_traders/core/theme/app_colors.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/theme/app_text.dart';
import 'package:al_asad_traders/core/theme/status_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Builds the application [ThemeData].
/// Rule: docs/DESIGN_SYSTEM.md > Theme files. Story: none.
ThemeData buildTheme([double textFactor = 1.0]) {
  final TextTheme textTheme = buildTextTheme(textFactor);

  const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.accent,
    onSecondary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceMuted,
    outline: AppColors.border,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    extensions: <ThemeExtension<dynamic>>[StatusColors.light()],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: textTheme.title.copyWith(color: AppColors.white),
      iconTheme: const IconThemeData(
        size: AppSizes.iconSize,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.buttonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: textTheme.bodyStrong,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.buttonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: textTheme.bodyStrong,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.buttonHeight),
        foregroundColor: AppColors.primary,
        side: const BorderSide(
          color: AppColors.border,
          width: AppSizes.borderWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: textTheme.bodyStrong,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.buttonHeight),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: textTheme.bodyStrong,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.m,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppSizes.borderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppSizes.borderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppSizes.focusWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppSizes.borderWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppSizes.focusWidth,
        ),
      ),
      labelStyle: textTheme.caption.copyWith(color: AppColors.onSurfaceMuted),
      floatingLabelStyle: textTheme.caption.copyWith(color: AppColors.primary),
      errorStyle: textTheme.caption.copyWith(color: AppColors.error),
      hintStyle: textTheme.body.copyWith(color: AppColors.onSurfaceMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.all(textTheme.caption),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(size: AppSizes.iconSize),
      ),
      elevation: 0,
      indicatorColor: AppColors.chipFinishedBackground,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: const BorderSide(
          color: AppColors.border,
          width: AppSizes.borderWidth,
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      labelStyle: textTheme.caption,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      titleTextStyle: textTheme.section,
      contentTextStyle: textTheme.body,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radius),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.onSurface,
      contentTextStyle: textTheme.body.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1.0,
      space: 1.0,
    ),
  );
}
