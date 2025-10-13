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
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;

  // Shadows
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
      offset: Offset(0, 2),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0, 0, 0, 0.12)
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> shadowXLarge = [
    BoxShadow(
      color: Color(0x29000000), // rgba(0, 0, 0, 0.16)
      offset: Offset(0, 16),
      blurRadius: 48,
    ),
  ];

  // Button shadows
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x338EB533), // rgba(142, 181, 51, 0.2)
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  // Animations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationStandard = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Curves
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.easeOutCubic;
  static const Curve curveAccelerate = Curves.easeInCubic;
  static const Curve curveSharp = Curves.easeInOut;

  // Button dimensions
  static const double buttonHeightLarge = 56;
  static const double buttonHeightMedium = 48;
  static const double buttonHeightSmall = 40;
  static const double buttonHeightIcon = 48;

  // Input dimensions
  static const double inputHeight = 48;
  static const double inputBorderWidth = 2;
  static const double inputBorderRadius = 12;

  // Card dimensions
  static const double cardBorderRadius = 16;
  static const double cardElevation = 0;

  // Icon sizes
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 20;
  static const double iconSizeLarge = 24;
  static const double iconSizeXLarge = 32;
  static const double iconSizeXXLarge = 48;

  // Touch targets
  static const double touchTargetMinSize = 44;

  // Breakpoints
  static const double breakpointMobile = 320;
  static const double breakpointMobileLarge = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
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
      width >= DesignTokens.breakpointTablet && width < DesignTokens.breakpointDesktop;

  /// Check if screen is desktop
  static bool isDesktop(double width) => width >= DesignTokens.breakpointDesktop;

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

  /// High contrast colors for accessibility
  static const Color highContrastText = Color(0xFF000000);
  static const Color highContrastBackground = Color(0xFFFFFFFF);
  static const Color highContrastBorder = Color(0xFF000000);
}
