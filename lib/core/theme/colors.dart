/// Color constants for the LandComp application
///
/// This file contains all color definitions from the style guide
/// including light theme, dark theme, and semantic colors.
library;

import 'package:flutter/material.dart';

/// Primary color palette
class AppColors {
  /// Private constructor to prevent instantiation
  AppColors._();

  // Primary Green Colors
  static const Color primaryGreen = Color(0xFF8EB533); // RGB: 142, 181, 51
  static const Color primaryGreenLight = Color(
    0xFFECF5CE,
  ); // RGB: 236, 245, 206
  static const Color primaryGreenDark = Color(0xFF6B8A26); // RGB: 107, 138, 38

  // Dark Teal Colors
  static const Color darkTeal = Color(0xFF005258); // RGB: 0, 82, 88
  static const Color lightGray = Color(0xFFF8F9FA); // RGB: 248, 249, 250

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // RGB: 16, 185, 129
  static const Color warning = Color(0xFFF59E0B); // RGB: 245, 158, 11
  static const Color error = Color(0xFFEF4444); // RGB: 239, 68, 68
  static const Color info = Color(0xFF3B82F6); // RGB: 59, 130, 246

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF); // RGB: 255, 255, 255
  static const Color black = Color(0xFF1A1A1A); // RGB: 26, 26, 26
  static const Color gray50 = Color(0xFFF9FAFB); // RGB: 249, 250, 251
  static const Color gray100 = Color(0xFFF3F4F6); // RGB: 243, 244, 246
  static const Color gray500 = Color(0xFF6B7280); // RGB: 107, 114, 128
  static const Color gray900 = Color(0xFF111827); // RGB: 17, 24, 39

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1A); // RGB: 26, 26, 26
  static const Color darkSurface = Color(0xFF2D2D2D); // RGB: 45, 45, 45
  static const Color darkText = Color(0xFFFFFFFF); // RGB: 255, 255, 255
  static const Color darkAccent = Color(0xFF9BC53D); // RGB: 155, 197, 61

  // Text Colors
  static const Color textPrimary = black;
  static const Color textSecondary = gray500;
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textAccent = darkTeal;
}

/// Light theme color scheme
class LightThemeColors {
  /// Private constructor to prevent instantiation
  LightThemeColors._();

  static const Color primary = AppColors.primaryGreen;
  static const Color onPrimary = AppColors.white;
  static const Color primaryContainer = AppColors.primaryGreenLight;
  static const Color onPrimaryContainer = AppColors.darkTeal;

  static const Color secondary = AppColors.darkTeal;
  static const Color onSecondary = AppColors.white;
  static const Color secondaryContainer = AppColors.lightGray;
  static const Color onSecondaryContainer = AppColors.darkTeal;

  static const Color tertiary = AppColors.success;
  static const Color onTertiary = AppColors.white;
  static const Color tertiaryContainer = Color(0xFFD1FAE5);
  static const Color onTertiaryContainer = Color(0xFF064E3B);

  static const Color error = AppColors.error;
  static const Color onError = AppColors.white;
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  static const Color background = AppColors.white;
  static const Color onBackground = AppColors.textPrimary;
  static const Color surface = AppColors.white;
  static const Color onSurface = AppColors.textPrimary;
  static const Color surfaceVariant = AppColors.gray50;
  static const Color onSurfaceVariant = AppColors.textSecondary;

  static const Color outline = AppColors.gray100;
  static const Color outlineVariant = AppColors.gray50;
  static const Color shadow = AppColors.black;
  static const Color scrim = AppColors.black;
  static const Color inverseSurface = AppColors.gray900;
  static const Color onInverseSurface = AppColors.white;
  static const Color inversePrimary = AppColors.primaryGreenLight;
}

/// Dark theme color scheme
class DarkThemeColors {
  /// Private constructor to prevent instantiation
  DarkThemeColors._();

  static const Color primary = AppColors.darkAccent;
  static const Color onPrimary = AppColors.darkBackground;
  static const Color primaryContainer = AppColors.darkTeal;
  static const Color onPrimaryContainer = AppColors.darkAccent;

  static const Color secondary = AppColors.darkAccent;
  static const Color onSecondary = AppColors.darkBackground;
  static const Color secondaryContainer = AppColors.darkSurface;
  static const Color onSecondaryContainer = AppColors.darkAccent;

  static const Color tertiary = AppColors.success;
  static const Color onTertiary = AppColors.darkBackground;
  static const Color tertiaryContainer = Color(0xFF064E3B);
  static const Color onTertiaryContainer = Color(0xFFD1FAE5);

  static const Color error = AppColors.error;
  static const Color onError = AppColors.darkBackground;
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color onErrorContainer = Color(0xFFFEE2E2);

  static const Color background = AppColors.darkBackground;
  static const Color onBackground = AppColors.darkText;
  static const Color surface = AppColors.darkSurface;
  static const Color onSurface = AppColors.darkText;
  static const Color surfaceVariant = Color(0xFF404040);
  static const Color onSurfaceVariant = Color(0xFF9CA3AF);

  static const Color outline = Color(0xFF404040);
  static const Color outlineVariant = Color(0xFF2D2D2D);
  static const Color shadow = AppColors.black;
  static const Color scrim = AppColors.black;
  static const Color inverseSurface = AppColors.white;
  static const Color onInverseSurface = AppColors.darkBackground;
  static const Color inversePrimary = AppColors.darkTeal;
}

/// Semantic color utilities
class SemanticColors {
  /// Private constructor to prevent instantiation
  SemanticColors._();

  /// Success colors
  static const Color success = AppColors.success;
  static const Color onSuccess = AppColors.white;
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF064E3B);

  /// Warning colors
  static const Color warning = AppColors.warning;
  static const Color onWarning = AppColors.white;
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF78350F);

  /// Error colors
  static const Color error = AppColors.error;
  static const Color onError = AppColors.white;
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  /// Info colors
  static const Color info = AppColors.info;
  static const Color onInfo = AppColors.white;
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfoContainer = Color(0xFF1E3A8A);
}

/// Gradient definitions
class AppGradients {
  /// Private constructor to prevent instantiation
  AppGradients._();

  /// Primary gradient: linear-gradient(135deg, #8EB533 0%, #005258 100%)
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGreen, AppColors.darkTeal],
  );

  /// Soft gradient: linear-gradient(135deg, #ECF5CE 0%, #D4E6A8 100%)
  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGreenLight, Color(0xFFD4E6A8)],
  );
}
