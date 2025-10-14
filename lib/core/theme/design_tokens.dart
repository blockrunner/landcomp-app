/// Design tokens for the LandComp application
///
/// This file contains all design tokens including colors, spacing,
/// typography, shadows, and animations following the style guide.
library;

import 'package:flutter/material.dart';

/// Main design tokens class
class DesignTokens {
  /// Private constructor to prevent instantiation
  DesignTokens._();

  // Colors - use classes directly
  // Spacing - use classes directly
  // Typography - use classes directly

  // Border radius
  /// Small border radius used for compact UI elements.
  static const double radiusSmall = 8;
  /// Medium border radius used for standard UI elements.
  static const double radiusMedium = 12;
  /// Large border radius used for cards and containers.
  static const double radiusLarge = 16;
  /// Extra-large border radius used for prominent surfaces.
  static const double radiusXLarge = 24;

  // Shadows
  /// Subtle shadow for low-elevation elements.
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Medium shadow for surfaces needing moderate elevation.
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
      offset: Offset(0, 2),
      blurRadius: 12,
    ),
  ];

  /// Large shadow for high-elevation components like modals.
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0, 0, 0, 0.12)
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  /// Extra-large shadow for very high elevation or overlays.
  static const List<BoxShadow> shadowXLarge = [
    BoxShadow(
      color: Color(0x29000000), // rgba(0, 0, 0, 0.16)
      offset: Offset(0, 16),
      blurRadius: 48,
    ),
  ];

  // Button shadows
  /// Shadow preset optimized for elevated buttons.
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x338EB533), // rgba(142, 181, 51, 0.2)
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  // Animations
  /// Fast animation duration for quick transitions.
  static const Duration animationFast = Duration(milliseconds: 150);
  /// Standard animation duration for most transitions.
  static const Duration animationStandard = Duration(milliseconds: 300);
  /// Slow animation duration for emphasized transitions.
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Curves
  /// Default motion curve matching Material guidance.
  static const Curve curveStandard = Curves.easeInOutCubic;
  /// Decelerating curve for exits and settling motions.
  static const Curve curveDecelerate = Curves.easeOutCubic;
  /// Accelerating curve for entrances and ramp-up motions.
  static const Curve curveAccelerate = Curves.easeInCubic;
  /// Sharp curve for snappy, direct transitions.
  static const Curve curveSharp = Curves.easeInOut;

  // Button dimensions
  /// Height for large buttons.
  static const double buttonHeightLarge = 56;
  /// Height for medium buttons.
  static const double buttonHeightMedium = 48;
  /// Height for small buttons.
  static const double buttonHeightSmall = 40;
  /// Height for icon-only buttons.
  static const double buttonHeightIcon = 48;

  // Input dimensions
  /// Standard input field height.
  static const double inputHeight = 48;
  /// Standard input border width.
  static const double inputBorderWidth = 2;
  /// Standard input border radius.
  static const double inputBorderRadius = 12;

  // Card dimensions
  /// Default card border radius.
  static const double cardBorderRadius = 16;
  /// Default card elevation.
  static const double cardElevation = 0;

  // Icon sizes
  /// Small icon size.
  static const double iconSizeSmall = 16;
  /// Medium icon size.
  static const double iconSizeMedium = 20;
  /// Large icon size.
  static const double iconSizeLarge = 24;
  /// Extra-large icon size.
  static const double iconSizeXLarge = 32;
  /// Extra-extra-large icon size.
  static const double iconSizeXXLarge = 48;

  // Touch targets
  /// Minimum size for accessible touch targets.
  static const double touchTargetMinSize = 44;

  // Breakpoints
  /// Minimum width for small mobile screens.
  static const double breakpointMobile = 320;
  /// Minimum width for large mobile screens.
  static const double breakpointMobileLarge = 480;
  /// Minimum width for tablet screens.
  static const double breakpointTablet = 768;
  /// Minimum width for desktop screens.
  static const double breakpointDesktop = 1024;
  /// Minimum width for large desktop screens.
  static const double breakpointDesktopLarge = 1440;
}

/// Animation utilities
class AnimationUtils {
  /// Private constructor to prevent instantiation
  AnimationUtils._();

  /// Standard transition duration
  static const Duration standardDuration = DesignTokens.animationStandard;

  /// Fast transition duration
  static const Duration fastDuration = DesignTokens.animationFast;

  /// Slow transition duration
  static const Duration slowDuration = DesignTokens.animationSlow;

  /// Standard curve
  static const Curve standardCurve = DesignTokens.curveStandard;

  /// Decelerate curve
  static const Curve decelerateCurve = DesignTokens.curveDecelerate;

  /// Accelerate curve
  static const Curve accelerateCurve = DesignTokens.curveAccelerate;

  /// Sharp curve
  static const Curve sharpCurve = DesignTokens.curveSharp;

  /// Create a standard animation controller
  static AnimationController createController(
    TickerProvider vsync, {
    Duration? duration,
    Duration? reverseDuration,
  }) {
    return AnimationController(
      duration: duration ?? standardDuration,
      reverseDuration: reverseDuration ?? standardDuration,
      vsync: vsync,
    );
  }

  /// Create a standard tween animation
  static Animation<T> createTween<T extends Object?>(
    TickerProvider vsync, {
    T? begin,
    T? end,
    Duration? duration,
    Curve? curve,
  }) {
    final controller = createController(vsync, duration: duration);
    return Tween<T>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve ?? standardCurve),
    );
  }
}

/// Responsive utilities
class ResponsiveUtils {
  /// Private constructor to prevent instantiation
  ResponsiveUtils._();

  /// Check if screen is mobile
  static bool isMobile(double width) => width < DesignTokens.breakpointTablet;

  /// Check if screen is tablet
  static bool isTablet(double width) =>
      width >= DesignTokens.breakpointTablet &&
      width < DesignTokens.breakpointDesktop;

  /// Check if screen is desktop
  static bool isDesktop(double width) =>
      width >= DesignTokens.breakpointDesktop;

  /// Get responsive value based on screen width
  static T responsive<T>({
    required T mobile,
    required T tablet,
    required T desktop,
    required double screenWidth,
  }) {
    if (isMobile(screenWidth)) {
      return mobile;
    } else if (isTablet(screenWidth)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(double baseSpacing, double screenWidth) {
    if (isMobile(screenWidth)) {
      return baseSpacing * 0.75;
    } else if (isTablet(screenWidth)) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.25;
    }
  }
}

/// Accessibility utilities
class AccessibilityUtils {
  /// Private constructor to prevent instantiation
  AccessibilityUtils._();

  /// Minimum touch target size
  static const double minTouchTarget = DesignTokens.touchTargetMinSize;

  /// Check if touch target meets minimum size requirements
  static bool isTouchTargetValid(double size) => size >= minTouchTarget;

  /// Get minimum padding for touch targets
  static EdgeInsets getTouchTargetPadding(double currentSize) {
    if (currentSize >= minTouchTarget) {
      return EdgeInsets.zero;
    }

    final padding = (minTouchTarget - currentSize) / 2;
    return EdgeInsets.all(padding);
  }

  /// High-contrast text color for maximum readability.
  static const Color highContrastText = Color(0xFF000000);
  /// High-contrast background color for accessibility use-cases.
  static const Color highContrastBackground = Color(0xFFFFFFFF);
  /// High-contrast border color to delineate elements clearly.
  static const Color highContrastBorder = Color(0xFF000000);
}
