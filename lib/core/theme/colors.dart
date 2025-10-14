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
  /// Primary green color used for main UI elements
  static const Color primaryGreen = Color(0xFF8EB533); // RGB: 142, 181, 51
  /// Light variant of primary green for containers and backgrounds
  static const Color primaryGreenLight = Color(
    0xFFECF5CE,
  ); // RGB: 236, 245, 206
  /// Dark variant of primary green for hover states and emphasis
  static const Color primaryGreenDark = Color(0xFF6B8A26); // RGB: 107, 138, 38

  // Dark Teal Colors
  /// Dark teal color for secondary elements and text
  static const Color darkTeal = Color(0xFF005258); // RGB: 0, 82, 88
  /// Light gray color for subtle backgrounds and surfaces
  static const Color lightGray = Color(0xFFF8F9FA); // RGB: 248, 249, 250

  // Semantic Colors
  /// Success color for positive actions and states
  static const Color success = Color(0xFF10B981); // RGB: 16, 185, 129
  /// Warning color for caution and attention states
  static const Color warning = Color(0xFFF59E0B); // RGB: 245, 158, 11
  /// Error color for negative actions and error states
  static const Color error = Color(0xFFEF4444); // RGB: 239, 68, 68
  /// Info color for informational messages and states
  static const Color info = Color(0xFF3B82F6); // RGB: 59, 130, 246

  // Neutral Colors
  /// Pure white color
  static const Color white = Color(0xFFFFFFFF); // RGB: 255, 255, 255
  /// Dark black color for text and high contrast elements
  static const Color black = Color(0xFF1A1A1A); // RGB: 26, 26, 26
  /// Very light gray for subtle backgrounds
  static const Color gray50 = Color(0xFFF9FAFB); // RGB: 249, 250, 251
  /// Light gray for borders and dividers
  static const Color gray100 = Color(0xFFF3F4F6); // RGB: 243, 244, 246
  /// Medium gray for secondary text and icons
  static const Color gray500 = Color(0xFF6B7280); // RGB: 107, 114, 128
  /// Very dark gray for high contrast text
  static const Color gray900 = Color(0xFF111827); // RGB: 17, 24, 39

  // Dark Theme Colors
  /// Dark background color for dark theme
  static const Color darkBackground = Color(0xFF1A1A1A); // RGB: 26, 26, 26
  /// Dark surface color for cards and elevated elements
  static const Color darkSurface = Color(0xFF2D2D2D); // RGB: 45, 45, 45
  /// Light text color for dark theme
  static const Color darkText = Color(0xFFFFFFFF); // RGB: 255, 255, 255
  /// Accent color for dark theme elements
  static const Color darkAccent = Color(0xFF9BC53D); // RGB: 155, 197, 61

  // Text Colors
  /// Primary text color for main content
  static const Color textPrimary = black;
  /// Secondary text color for less important content
  static const Color textSecondary = gray500;
  /// Tertiary text color for subtle information
  static const Color textTertiary = Color(0xFF9CA3AF);
  /// Accent text color for highlighted content
  static const Color textAccent = darkTeal;
}

/// Light theme color scheme
class LightThemeColors {
  /// Private constructor to prevent instantiation
  LightThemeColors._();

  /// Primary color for light theme
  static const Color primary = AppColors.primaryGreen;
  /// Color for content on primary background
  static const Color onPrimary = AppColors.white;
  /// Container color for primary elements
  static const Color primaryContainer = AppColors.primaryGreenLight;
  /// Color for content on primary container
  static const Color onPrimaryContainer = AppColors.darkTeal;

  /// Secondary color for light theme
  static const Color secondary = AppColors.darkTeal;
  /// Color for content on secondary background
  static const Color onSecondary = AppColors.white;
  /// Container color for secondary elements
  static const Color secondaryContainer = AppColors.lightGray;
  /// Color for content on secondary container
  static const Color onSecondaryContainer = AppColors.darkTeal;

  /// Tertiary color for light theme
  static const Color tertiary = AppColors.success;
  /// Color for content on tertiary background
  static const Color onTertiary = AppColors.white;
  /// Container color for tertiary elements
  static const Color tertiaryContainer = Color(0xFFD1FAE5);
  /// Color for content on tertiary container
  static const Color onTertiaryContainer = Color(0xFF064E3B);

  /// Error color for light theme
  static const Color error = AppColors.error;
  /// Color for content on error background
  static const Color onError = AppColors.white;
  /// Container color for error elements
  static const Color errorContainer = Color(0xFFFEE2E2);
  /// Color for content on error container
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  /// Background color for light theme
  static const Color background = AppColors.white;
  /// Color for content on background
  static const Color onBackground = AppColors.textPrimary;
  /// Surface color for light theme
  static const Color surface = AppColors.white;
  /// Color for content on surface
  static const Color onSurface = AppColors.textPrimary;
  /// Variant surface color for elevated elements
  static const Color surfaceVariant = AppColors.gray50;
  /// Color for content on surface variant
  static const Color onSurfaceVariant = AppColors.textSecondary;

  /// Outline color for borders and dividers
  static const Color outline = AppColors.gray100;
  /// Variant outline color for subtle borders
  static const Color outlineVariant = AppColors.gray50;
  /// Shadow color for elevation effects
  static const Color shadow = AppColors.black;
  /// Scrim color for overlays and modals
  static const Color scrim = AppColors.black;
  /// Inverse surface color for contrast elements
  static const Color inverseSurface = AppColors.gray900;
  /// Color for content on inverse surface
  static const Color onInverseSurface = AppColors.white;
  /// Inverse primary color for contrast elements
  static const Color inversePrimary = AppColors.primaryGreenLight;
}

/// Dark theme color scheme
class DarkThemeColors {
  /// Private constructor to prevent instantiation
  DarkThemeColors._();

  /// Primary color for dark theme
  static const Color primary = AppColors.darkAccent;
  /// Color for content on primary background
  static const Color onPrimary = AppColors.darkBackground;
  /// Container color for primary elements
  static const Color primaryContainer = AppColors.darkTeal;
  /// Color for content on primary container
  static const Color onPrimaryContainer = AppColors.darkAccent;

  /// Secondary color for dark theme
  static const Color secondary = AppColors.darkAccent;
  /// Color for content on secondary background
  static const Color onSecondary = AppColors.darkBackground;
  /// Container color for secondary elements
  static const Color secondaryContainer = AppColors.darkSurface;
  /// Color for content on secondary container
  static const Color onSecondaryContainer = AppColors.darkAccent;

  /// Tertiary color for dark theme
  static const Color tertiary = AppColors.success;
  /// Color for content on tertiary background
  static const Color onTertiary = AppColors.darkBackground;
  /// Container color for tertiary elements
  static const Color tertiaryContainer = Color(0xFF064E3B);
  /// Color for content on tertiary container
  static const Color onTertiaryContainer = Color(0xFFD1FAE5);

  /// Error color for dark theme
  static const Color error = AppColors.error;
  /// Color for content on error background
  static const Color onError = AppColors.darkBackground;
  /// Container color for error elements
  static const Color errorContainer = Color(0xFF7F1D1D);
  /// Color for content on error container
  static const Color onErrorContainer = Color(0xFFFEE2E2);

  /// Background color for dark theme
  static const Color background = AppColors.darkBackground;
  /// Color for content on background
  static const Color onBackground = AppColors.darkText;
  /// Surface color for dark theme
  static const Color surface = AppColors.darkSurface;
  /// Color for content on surface
  static const Color onSurface = AppColors.darkText;
  /// Variant surface color for elevated elements
  static const Color surfaceVariant = Color(0xFF404040);
  /// Color for content on surface variant
  static const Color onSurfaceVariant = Color(0xFF9CA3AF);

  /// Outline color for borders and dividers
  static const Color outline = Color(0xFF404040);
  /// Variant outline color for subtle borders
  static const Color outlineVariant = Color(0xFF2D2D2D);
  /// Shadow color for elevation effects
  static const Color shadow = AppColors.black;
  /// Scrim color for overlays and modals
  static const Color scrim = AppColors.black;
  /// Inverse surface color for contrast elements
  static const Color inverseSurface = AppColors.white;
  /// Color for content on inverse surface
  static const Color onInverseSurface = AppColors.darkBackground;
  /// Inverse primary color for contrast elements
  static const Color inversePrimary = AppColors.darkTeal;
}

/// Semantic color utilities
class SemanticColors {
  /// Private constructor to prevent instantiation
  SemanticColors._();

  /// Success colors
  /// Success color for positive states
  static const Color success = AppColors.success;
  /// Color for content on success background
  static const Color onSuccess = AppColors.white;
  /// Container color for success elements
  static const Color successContainer = Color(0xFFD1FAE5);
  /// Color for content on success container
  static const Color onSuccessContainer = Color(0xFF064E3B);

  /// Warning colors
  /// Warning color for caution states
  static const Color warning = AppColors.warning;
  /// Color for content on warning background
  static const Color onWarning = AppColors.white;
  /// Container color for warning elements
  static const Color warningContainer = Color(0xFFFEF3C7);
  /// Color for content on warning container
  static const Color onWarningContainer = Color(0xFF78350F);

  /// Error colors
  /// Error color for negative states
  static const Color error = AppColors.error;
  /// Color for content on error background
  static const Color onError = AppColors.white;
  /// Container color for error elements
  static const Color errorContainer = Color(0xFFFEE2E2);
  /// Color for content on error container
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  /// Info colors
  /// Info color for informational states
  static const Color info = AppColors.info;
  /// Color for content on info background
  static const Color onInfo = AppColors.white;
  /// Container color for info elements
  static const Color infoContainer = Color(0xFFDBEAFE);
  /// Color for content on info container
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
