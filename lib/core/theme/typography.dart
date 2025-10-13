/// Typography system for the LandComp application
/// 
/// This file contains typography definitions following the style guide
/// with responsive font sizes and proper line heights.
library;

import 'package:flutter/material.dart';

/// Typography scale following the style guide
class AppTypography {
  /// Private constructor to prevent instantiation
  AppTypography._();

  /// Display text style - 3.5rem, font-weight: 800, line-height: 1.1
  static TextStyle get display => const TextStyle(
    fontSize: 56, // 3.5rem
    fontWeight: FontWeight.w800,
    height: 1.1,
    fontFamily: 'Inter',
  );

  /// H1 - clamp(2.5rem, 5vw, 4rem), font-weight: 800, line-height: 1.1
  static TextStyle get h1 => const TextStyle(
    fontSize: 40, // 2.5rem base
    fontWeight: FontWeight.w800,
    height: 1.1,
    fontFamily: 'Inter',
  );

  /// H2 - clamp(2rem, 4vw, 3rem), font-weight: 700, line-height: 1.2
  static TextStyle get h2 => const TextStyle(
    fontSize: 32, // 2rem base
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFamily: 'Inter',
  );

  /// H3 - clamp(1.5rem, 3vw, 2rem), font-weight: 600, line-height: 1.3
  static TextStyle get h3 => const TextStyle(
    fontSize: 24, // 1.5rem base
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: 'Inter',
  );

  /// H4 - clamp(1.25rem, 2.5vw, 1.5rem), font-weight: 600, line-height: 1.4
  static TextStyle get h4 => const TextStyle(
    fontSize: 20, // 1.25rem base
    fontWeight: FontWeight.w600,
    height: 1.4,
    fontFamily: 'Inter',
  );

  /// H5 - clamp(1.125rem, 2vw, 1.25rem), font-weight: 500, line-height: 1.4
  static TextStyle get h5 => const TextStyle(
    fontSize: 18, // 1.125rem base
    fontWeight: FontWeight.w500,
    height: 1.4,
    fontFamily: 'Inter',
  );

  /// H6 - clamp(1rem, 1.5vw, 1.125rem), font-weight: 500, line-height: 1.5
  static TextStyle get h6 => const TextStyle(
    fontSize: 16, // 1rem base
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: 'Inter',
  );

  /// Lead - 20px, font-weight: 400, line-height: 1.6
  static TextStyle get lead => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.6,
    fontFamily: 'Inter',
  );

  /// Body Large - 18px, font-weight: 400, line-height: 1.6
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    fontFamily: 'Inter',
  );

  /// Body - 16px, font-weight: 400, line-height: 1.6
  static TextStyle get body => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    fontFamily: 'Inter',
  );

  /// Body Small - 14px, font-weight: 400, line-height: 1.5
  static TextStyle get bodySmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: 'Inter',
  );

  /// Button Large - 18px, font-weight: 600, line-height: 1.2
  static TextStyle get buttonLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFamily: 'Inter',
  );

  /// Button - 16px, font-weight: 600, line-height: 1.2
  static TextStyle get button => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFamily: 'Inter',
  );

  /// Button Small - 14px, font-weight: 500, line-height: 1.2
  static TextStyle get buttonSmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    fontFamily: 'Inter',
  );

  /// Navigation - 16px, font-weight: 500, line-height: 1.2
  static TextStyle get navigation => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
    fontFamily: 'Inter',
  );

  /// Caption - 12px, font-weight: 400, line-height: 1.4
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    fontFamily: 'Inter',
  );

  /// Code - 14px, font-family: JetBrains Mono, line-height: 1.5
  static TextStyle get code => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: 'JetBrainsMono',
  );
}

/// Responsive typography utilities
class ResponsiveTypography {
  /// Private constructor to prevent instantiation
  ResponsiveTypography._();

  /// Get responsive font size using clamp-like behavior
  static double getResponsiveFontSize({
    required double minSize,
    required double maxSize,
    required double screenWidth,
    double? preferredSize,
  }) {
    final preferred = preferredSize ?? (minSize + maxSize) / 2;
    
    // Calculate viewport-based size (similar to CSS vw)
    final viewportSize = screenWidth * 0.05; // 5vw equivalent
    
    // Clamp the size between min and max
    return (preferred + viewportSize).clamp(minSize, maxSize);
  }

  /// Get responsive H1 font size
  static double getH1FontSize(double screenWidth) {
    return getResponsiveFontSize(
      minSize: 40, // 2.5rem
      maxSize: 64, // 4rem
      screenWidth: screenWidth,
    );
  }

  /// Get responsive H2 font size
  static double getH2FontSize(double screenWidth) {
    return getResponsiveFontSize(
      minSize: 32, // 2rem
      maxSize: 48, // 3rem
      screenWidth: screenWidth,
    );
  }

  /// Get responsive H3 font size
  static double getH3FontSize(double screenWidth) {
    return getResponsiveFontSize(
      minSize: 24, // 1.5rem
      maxSize: 32, // 2rem
      screenWidth: screenWidth,
    );
  }

  /// Get responsive H4 font size
  static double getH4FontSize(double screenWidth) {
    return getResponsiveFontSize(
      minSize: 20, // 1.25rem
      maxSize: 24, // 1.5rem
      screenWidth: screenWidth,
    );
  }

  /// Get responsive H5 font size
  static double getH5FontSize(double screenWidth) {
    return getResponsiveFontSize(
      minSize: 18, // 1.125rem
      maxSize: 20, // 1.25rem
      screenWidth: screenWidth,
    );
  }

  /// Get responsive H6 font size
  static double getH6FontSize(double screenWidth) {
    return getResponsiveFontSize(
      minSize: 16, // 1rem
      maxSize: 18, // 1.125rem
      screenWidth: screenWidth,
    );
  }
}

/// Text theme for Material Design
class AppTextTheme {
  /// Private constructor to prevent instantiation
  AppTextTheme._();

  /// Light theme text styles
  static TextTheme get lightTextTheme {
    return const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      displayMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      displaySmall: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        fontFamily: 'Inter',
        color: Color(0xFF6B7280),
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFF1A1A1A),
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        fontFamily: 'Inter',
        color: Color(0xFF6B7280),
      ),
    );
  }

  /// Dark theme text styles
  static TextTheme get darkTextTheme {
    return const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      displayMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      displaySmall: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        fontFamily: 'Inter',
        color: Color(0xFF9CA3AF),
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        fontFamily: 'Inter',
        color: Color(0xFFFFFFFF),
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        fontFamily: 'Inter',
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}
