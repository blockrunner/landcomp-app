/// Theme extensions for the LandComp application
///
/// This file contains custom theme extensions that provide
/// additional colors and styles beyond the standard Material Design theme.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';

/// Custom colors extension
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primaryGreen,
    required this.primaryGreenLight,
    required this.primaryGreenDark,
    required this.darkTeal,
    required this.lightGray,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textAccent,
  });

  final Color primaryGreen;
  final Color primaryGreenLight;
  final Color primaryGreenDark;
  final Color darkTeal;
  final Color lightGray;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textAccent;

  @override
  AppColorsExtension copyWith({
    Color? primaryGreen,
    Color? primaryGreenLight,
    Color? primaryGreenDark,
    Color? darkTeal,
    Color? lightGray,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textAccent,
  }) {
    return AppColorsExtension(
      primaryGreen: primaryGreen ?? this.primaryGreen,
      primaryGreenLight: primaryGreenLight ?? this.primaryGreenLight,
      primaryGreenDark: primaryGreenDark ?? this.primaryGreenDark,
      darkTeal: darkTeal ?? this.darkTeal,
      lightGray: lightGray ?? this.lightGray,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textAccent: textAccent ?? this.textAccent,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      primaryGreenLight: Color.lerp(
        primaryGreenLight,
        other.primaryGreenLight,
        t,
      )!,
      primaryGreenDark: Color.lerp(
        primaryGreenDark,
        other.primaryGreenDark,
        t,
      )!,
      darkTeal: Color.lerp(darkTeal, other.darkTeal, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
    );
  }

  /// Light theme colors
  static const AppColorsExtension light = AppColorsExtension(
    primaryGreen: AppColors.primaryGreen,
    primaryGreenLight: AppColors.primaryGreenLight,
    primaryGreenDark: AppColors.primaryGreenDark,
    darkTeal: AppColors.darkTeal,
    lightGray: AppColors.lightGray,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    textAccent: AppColors.textAccent,
  );

  /// Dark theme colors
  static const AppColorsExtension dark = AppColorsExtension(
    primaryGreen: AppColors.darkAccent,
    primaryGreenLight: AppColors.primaryGreenLight,
    primaryGreenDark: AppColors.primaryGreenDark,
    darkTeal: AppColors.darkTeal,
    lightGray: AppColors.darkSurface,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    textPrimary: AppColors.darkText,
    textSecondary: Color(0xFF9CA3AF),
    textTertiary: Color(0xFF6B7280),
    textAccent: AppColors.darkAccent,
  );
}

/// Custom spacing extension
@immutable
class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  const AppSpacingExtension({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.containerPadding,
    required this.sectionSpacing,
    required this.elementSpacing,
    required this.internalPadding,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double containerPadding;
  final double sectionSpacing;
  final double elementSpacing;
  final double internalPadding;

  @override
  AppSpacingExtension copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? containerPadding,
    double? sectionSpacing,
    double? elementSpacing,
    double? internalPadding,
  }) {
    return AppSpacingExtension(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      containerPadding: containerPadding ?? this.containerPadding,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      elementSpacing: elementSpacing ?? this.elementSpacing,
      internalPadding: internalPadding ?? this.internalPadding,
    );
  }

  @override
  AppSpacingExtension lerp(
    ThemeExtension<AppSpacingExtension>? other,
    double t,
  ) {
    if (other is! AppSpacingExtension) {
      return this;
    }
    return AppSpacingExtension(
      xs: xs + (other.xs - xs) * t,
      sm: sm + (other.sm - sm) * t,
      md: md + (other.md - md) * t,
      lg: lg + (other.lg - lg) * t,
      xl: xl + (other.xl - xl) * t,
      xxl: xxl + (other.xxl - xxl) * t,
      xxxl: xxxl + (other.xxxl - xxxl) * t,
      containerPadding:
          containerPadding + (other.containerPadding - containerPadding) * t,
      sectionSpacing:
          sectionSpacing + (other.sectionSpacing - sectionSpacing) * t,
      elementSpacing:
          elementSpacing + (other.elementSpacing - elementSpacing) * t,
      internalPadding:
          internalPadding + (other.internalPadding - internalPadding) * t,
    );
  }

  /// Standard spacing values
  static const AppSpacingExtension standard = AppSpacingExtension(
    xs: AppSpacing.xs,
    sm: AppSpacing.sm,
    md: AppSpacing.md,
    lg: AppSpacing.lg,
    xl: AppSpacing.xl,
    xxl: AppSpacing.xxl,
    xxxl: AppSpacing.xxxl,
    containerPadding: AppSpacing.containerPadding,
    sectionSpacing: AppSpacing.sectionSpacing,
    elementSpacing: AppSpacing.elementSpacing,
    internalPadding: AppSpacing.internalPadding,
  );
}

/// Custom typography extension
@immutable
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  const AppTypographyExtension({
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.h6,
    required this.lead,
    required this.bodyLarge,
    required this.body,
    required this.bodySmall,
    required this.buttonLarge,
    required this.button,
    required this.buttonSmall,
    required this.navigation,
    required this.caption,
    required this.code,
  });

  final TextStyle display;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle lead;
  final TextStyle bodyLarge;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle buttonLarge;
  final TextStyle button;
  final TextStyle buttonSmall;
  final TextStyle navigation;
  final TextStyle caption;
  final TextStyle code;

  @override
  AppTypographyExtension copyWith({
    TextStyle? display,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? h5,
    TextStyle? h6,
    TextStyle? lead,
    TextStyle? bodyLarge,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? buttonLarge,
    TextStyle? button,
    TextStyle? buttonSmall,
    TextStyle? navigation,
    TextStyle? caption,
    TextStyle? code,
  }) {
    return AppTypographyExtension(
      display: display ?? this.display,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      h5: h5 ?? this.h5,
      h6: h6 ?? this.h6,
      lead: lead ?? this.lead,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      buttonLarge: buttonLarge ?? this.buttonLarge,
      button: button ?? this.button,
      buttonSmall: buttonSmall ?? this.buttonSmall,
      navigation: navigation ?? this.navigation,
      caption: caption ?? this.caption,
      code: code ?? this.code,
    );
  }

  @override
  AppTypographyExtension lerp(
    ThemeExtension<AppTypographyExtension>? other,
    double t,
  ) {
    if (other is! AppTypographyExtension) {
      return this;
    }
    return AppTypographyExtension(
      display: TextStyle.lerp(display, other.display, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      h4: TextStyle.lerp(h4, other.h4, t)!,
      h5: TextStyle.lerp(h5, other.h5, t)!,
      h6: TextStyle.lerp(h6, other.h6, t)!,
      lead: TextStyle.lerp(lead, other.lead, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      buttonLarge: TextStyle.lerp(buttonLarge, other.buttonLarge, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      buttonSmall: TextStyle.lerp(buttonSmall, other.buttonSmall, t)!,
      navigation: TextStyle.lerp(navigation, other.navigation, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      code: TextStyle.lerp(code, other.code, t)!,
    );
  }

  /// Light theme typography
  static AppTypographyExtension get light => AppTypographyExtension(
    display: AppTypography.display,
    h1: AppTypography.h1,
    h2: AppTypography.h2,
    h3: AppTypography.h3,
    h4: AppTypography.h4,
    h5: AppTypography.h5,
    h6: AppTypography.h6,
    lead: AppTypography.lead,
    bodyLarge: AppTypography.bodyLarge,
    body: AppTypography.body,
    bodySmall: AppTypography.bodySmall,
    buttonLarge: AppTypography.buttonLarge,
    button: AppTypography.button,
    buttonSmall: AppTypography.buttonSmall,
    navigation: AppTypography.navigation,
    caption: AppTypography.caption,
    code: AppTypography.code,
  );

  /// Dark theme typography
  static AppTypographyExtension get dark => AppTypographyExtension(
    display: AppTypography.display,
    h1: AppTypography.h1,
    h2: AppTypography.h2,
    h3: AppTypography.h3,
    h4: AppTypography.h4,
    h5: AppTypography.h5,
    h6: AppTypography.h6,
    lead: AppTypography.lead,
    bodyLarge: AppTypography.bodyLarge,
    body: AppTypography.body,
    bodySmall: AppTypography.bodySmall,
    buttonLarge: AppTypography.buttonLarge,
    button: AppTypography.button,
    buttonSmall: AppTypography.buttonSmall,
    navigation: AppTypography.navigation,
    caption: AppTypography.caption,
    code: AppTypography.code,
  );
}

/// Extension methods for easy access to custom theme data
extension ThemeDataExtensions on ThemeData {
  /// Get custom colors
  AppColorsExtension get appColors => extension<AppColorsExtension>()!;

  /// Get custom spacing
  AppSpacingExtension get appSpacing => extension<AppSpacingExtension>()!;

  /// Get custom typography
  AppTypographyExtension get appTypography =>
      extension<AppTypographyExtension>()!;
}

/// Extension methods for BuildContext
extension ThemeExtensions on BuildContext {
  /// Get custom colors
  AppColorsExtension get appColors => Theme.of(this).appColors;

  /// Get custom spacing
  AppSpacingExtension get appSpacing => Theme.of(this).appSpacing;

  /// Get custom typography
  AppTypographyExtension get appTypography => Theme.of(this).appTypography;
}
