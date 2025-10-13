/// Spacing system for the LandComp application
///
/// This file contains spacing constants following the 8px grid system
/// and responsive spacing utilities.
library;

import 'package:flutter/material.dart';

/// Spacing constants following the 8px grid system
class AppSpacing {
  /// Private constructor to prevent instantiation
  AppSpacing._();

  /// Extra small spacing - 4px
  static const double xs = 4;

  /// Small spacing - 8px
  static const double sm = 8;

  /// Medium spacing - 16px
  static const double md = 16;

  /// Large spacing - 24px
  static const double lg = 24;

  /// Extra large spacing - 32px
  static const double xl = 32;

  /// 2X large spacing - 48px
  static const double xxl = 48;

  /// 3X large spacing - 64px
  static const double xxxl = 64;

  /// Container padding - 16px
  static const double containerPadding = md;

  /// Section spacing - 32px
  static const double sectionSpacing = xl;

  /// Element spacing - 16px
  static const double elementSpacing = md;

  /// Internal padding - 20px
  static const double internalPadding = 20;
}

/// Responsive spacing utilities
class ResponsiveSpacing {
  /// Private constructor to prevent instantiation
  ResponsiveSpacing._();

  /// Get responsive spacing based on screen width
  static double getResponsiveSpacing(double baseSpacing, double screenWidth) {
    if (screenWidth < 480) {
      // Mobile: reduce spacing by 25%
      return baseSpacing * 0.75;
    } else if (screenWidth < 768) {
      // Mobile large: keep base spacing
      return baseSpacing;
    } else if (screenWidth < 1024) {
      // Tablet: increase spacing by 25%
      return baseSpacing * 1.25;
    } else {
      // Desktop: increase spacing by 50%
      return baseSpacing * 1.5;
    }
  }

  /// Get responsive container padding
  static double getContainerPadding(double screenWidth) {
    return getResponsiveSpacing(AppSpacing.containerPadding, screenWidth);
  }

  /// Get responsive section spacing
  static double getSectionSpacing(double screenWidth) {
    return getResponsiveSpacing(AppSpacing.sectionSpacing, screenWidth);
  }

  /// Get responsive element spacing
  static double getElementSpacing(double screenWidth) {
    return getResponsiveSpacing(AppSpacing.elementSpacing, screenWidth);
  }
}

/// Edge insets utilities
class AppEdgeInsets {
  /// Private constructor to prevent instantiation
  AppEdgeInsets._();

  /// All sides with same spacing
  static EdgeInsets all(double spacing) => EdgeInsets.all(spacing);

  /// Horizontal spacing only
  static EdgeInsets horizontal(double spacing) =>
      EdgeInsets.symmetric(horizontal: spacing);

  /// Vertical spacing only
  static EdgeInsets vertical(double spacing) =>
      EdgeInsets.symmetric(vertical: spacing);

  /// Symmetric spacing
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Only specific sides
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Predefined common spacing combinations
  static EdgeInsets get xs => all(AppSpacing.xs);
  static EdgeInsets get sm => all(AppSpacing.sm);
  static EdgeInsets get md => all(AppSpacing.md);
  static EdgeInsets get lg => all(AppSpacing.lg);
  static EdgeInsets get xl => all(AppSpacing.xl);
  static EdgeInsets get xxl => all(AppSpacing.xxl);
  static EdgeInsets get xxxl => all(AppSpacing.xxxl);

  // Horizontal only
  static EdgeInsets get horizontalXs => horizontal(AppSpacing.xs);
  static EdgeInsets get horizontalSm => horizontal(AppSpacing.sm);
  static EdgeInsets get horizontalMd => horizontal(AppSpacing.md);
  static EdgeInsets get horizontalLg => horizontal(AppSpacing.lg);
  static EdgeInsets get horizontalXl => horizontal(AppSpacing.xl);

  // Vertical only
  static EdgeInsets get verticalXs => vertical(AppSpacing.xs);
  static EdgeInsets get verticalSm => vertical(AppSpacing.sm);
  static EdgeInsets get verticalMd => vertical(AppSpacing.md);
  static EdgeInsets get verticalLg => vertical(AppSpacing.lg);
  static EdgeInsets get verticalXl => vertical(AppSpacing.xl);

  // Container padding
  static EdgeInsets get container => all(AppSpacing.containerPadding);
  static EdgeInsets get containerHorizontal =>
      horizontal(AppSpacing.containerPadding);
  static EdgeInsets get containerVertical =>
      vertical(AppSpacing.containerPadding);

  // Section spacing
  static EdgeInsets get section => all(AppSpacing.sectionSpacing);
  static EdgeInsets get sectionHorizontal =>
      horizontal(AppSpacing.sectionSpacing);
  static EdgeInsets get sectionVertical => vertical(AppSpacing.sectionSpacing);
}
