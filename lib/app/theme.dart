/// Application theme configuration
///
/// This file contains the theme setup for both light and dark modes
/// following the LandComp style guide and Material Design 3 guidelines.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/theme_extensions.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';

/// Application theme configuration
class AppTheme {
  /// Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: LightThemeColors.primary,
        primaryContainer: LightThemeColors.primaryContainer,
        onPrimaryContainer: LightThemeColors.onPrimaryContainer,
        secondary: LightThemeColors.secondary,
        onSecondary: LightThemeColors.onSecondary,
        secondaryContainer: LightThemeColors.secondaryContainer,
        onSecondaryContainer: LightThemeColors.onSecondaryContainer,
        tertiary: LightThemeColors.tertiary,
        onTertiary: LightThemeColors.onTertiary,
        tertiaryContainer: LightThemeColors.tertiaryContainer,
        onTertiaryContainer: LightThemeColors.onTertiaryContainer,
        error: LightThemeColors.error,
        errorContainer: LightThemeColors.errorContainer,
        onErrorContainer: LightThemeColors.onErrorContainer,
        onSurface: LightThemeColors.onSurface,
        surfaceContainerHighest: LightThemeColors.surfaceVariant,
        onSurfaceVariant: LightThemeColors.onSurfaceVariant,
        outline: LightThemeColors.outline,
        outlineVariant: LightThemeColors.outlineVariant,
        shadow: LightThemeColors.shadow,
        scrim: LightThemeColors.scrim,
        inverseSurface: LightThemeColors.inverseSurface,
        onInverseSurface: LightThemeColors.onInverseSurface,
        inversePrimary: LightThemeColors.inversePrimary,
      ),

      // Text theme
      textTheme: AppTextTheme.lightTextTheme,

      // App bar theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: LightThemeColors.surface,
        foregroundColor: LightThemeColors.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: LightThemeColors.onSurface,
          fontFamily: 'Inter',
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.cardBorderRadius),
        ),
        color: LightThemeColors.surface,
        shadowColor: Colors.transparent,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMedium),
          textStyle: AppTypography.button,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMedium),
          textStyle: AppTypography.button,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMedium),
          textStyle: AppTypography.button,
          side: const BorderSide(color: LightThemeColors.outline),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightThemeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: LightThemeColors.outline,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: LightThemeColors.outline,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: LightThemeColors.primary,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: LightThemeColors.error,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: LightThemeColors.error,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.body.copyWith(
          color: LightThemeColors.onSurfaceVariant,
        ),
        labelStyle: AppTypography.body.copyWith(
          color: LightThemeColors.onSurfaceVariant,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightThemeColors.surface,
        selectedItemColor: LightThemeColors.primary,
        unselectedItemColor: LightThemeColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: LightThemeColors.primary,
        foregroundColor: LightThemeColors.onPrimary,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: LightThemeColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: LightThemeColors.onSurface,
        size: DesignTokens.iconSizeLarge,
      ),

      // Primary icon theme
      primaryIconTheme: const IconThemeData(
        color: LightThemeColors.onPrimary,
        size: DesignTokens.iconSizeLarge,
      ),

      // Theme extensions
      extensions: [
        AppColorsExtension.light,
        AppSpacingExtension.standard,
        AppTypographyExtension.light,
      ],
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: DarkThemeColors.primary,
        onPrimary: DarkThemeColors.onPrimary,
        primaryContainer: DarkThemeColors.primaryContainer,
        onPrimaryContainer: DarkThemeColors.onPrimaryContainer,
        secondary: DarkThemeColors.secondary,
        onSecondary: DarkThemeColors.onSecondary,
        secondaryContainer: DarkThemeColors.secondaryContainer,
        onSecondaryContainer: DarkThemeColors.onSecondaryContainer,
        tertiary: DarkThemeColors.tertiary,
        onTertiary: DarkThemeColors.onTertiary,
        tertiaryContainer: DarkThemeColors.tertiaryContainer,
        onTertiaryContainer: DarkThemeColors.onTertiaryContainer,
        error: DarkThemeColors.error,
        onError: DarkThemeColors.onError,
        errorContainer: DarkThemeColors.errorContainer,
        onErrorContainer: DarkThemeColors.onErrorContainer,
        surface: DarkThemeColors.surface,
        surfaceContainerHighest: DarkThemeColors.surfaceVariant,
        onSurfaceVariant: DarkThemeColors.onSurfaceVariant,
        outline: DarkThemeColors.outline,
        outlineVariant: DarkThemeColors.outlineVariant,
        shadow: DarkThemeColors.shadow,
        scrim: DarkThemeColors.scrim,
        inverseSurface: DarkThemeColors.inverseSurface,
        onInverseSurface: DarkThemeColors.onInverseSurface,
        inversePrimary: DarkThemeColors.inversePrimary,
      ),

      // Text theme
      textTheme: AppTextTheme.darkTextTheme,

      // App bar theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DarkThemeColors.surface,
        foregroundColor: DarkThemeColors.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DarkThemeColors.onSurface,
          fontFamily: 'Inter',
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.cardBorderRadius),
        ),
        color: DarkThemeColors.surface,
        shadowColor: Colors.transparent,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMedium),
          textStyle: AppTypography.button,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMedium),
          textStyle: AppTypography.button,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMedium),
          textStyle: AppTypography.button,
          side: const BorderSide(color: DarkThemeColors.outline),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkThemeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: DarkThemeColors.outline,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: DarkThemeColors.outline,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: DarkThemeColors.primary,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: DarkThemeColors.error,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
          borderSide: const BorderSide(
            color: DarkThemeColors.error,
            width: DesignTokens.inputBorderWidth,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.body.copyWith(
          color: DarkThemeColors.onSurfaceVariant,
        ),
        labelStyle: AppTypography.body.copyWith(
          color: DarkThemeColors.onSurfaceVariant,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkThemeColors.surface,
        selectedItemColor: DarkThemeColors.primary,
        unselectedItemColor: DarkThemeColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DarkThemeColors.primary,
        foregroundColor: DarkThemeColors.onPrimary,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: DarkThemeColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: DarkThemeColors.onSurface,
        size: DesignTokens.iconSizeLarge,
      ),

      // Primary icon theme
      primaryIconTheme: const IconThemeData(
        color: DarkThemeColors.onPrimary,
        size: DesignTokens.iconSizeLarge,
      ),

      // Theme extensions
      extensions: [
        AppColorsExtension.dark,
        AppSpacingExtension.standard,
        AppTypographyExtension.dark,
      ],
    );
  }
}
