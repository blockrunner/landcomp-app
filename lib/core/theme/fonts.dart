/// Font constants for the LandComp application
/// 
/// This file contains font family constants and utilities
/// for consistent typography across the app.
library;

/// Font family constants
class AppFonts {
  /// Private constructor to prevent instantiation
  AppFonts._();

  /// Primary font family - Inter
  static const String inter = 'Inter';
  
  /// Monospace font family - JetBrains Mono
  static const String jetBrainsMono = 'JetBrainsMono';
  
  /// Fallback font families
  static const List<String> fallbackFonts = [
    'system-ui',
    '-apple-system',
    'BlinkMacSystemFont',
    'sans-serif',
  ];
}

/// Font weight constants
class FontWeights {
  /// Private constructor to prevent instantiation
  FontWeights._();

  /// Regular weight (400)
  static const int regular = 400;
  
  /// Medium weight (500)
  static const int medium = 500;
  
  /// Semi-bold weight (600)
  static const int semiBold = 600;
  
  /// Bold weight (700)
  static const int bold = 700;
  
  /// Extra bold weight (800)
  static const int extraBold = 800;
}

/// Typography utilities
class TypographyUtils {
  /// Private constructor to prevent instantiation
  TypographyUtils._();

  /// Get font family with fallbacks
  static String getFontFamily(String primaryFont) {
    return '$primaryFont, ${AppFonts.fallbackFonts.join(', ')}';
  }
  
  /// Get Inter font family with fallbacks
  static String get interFontFamily => getFontFamily(AppFonts.inter);
  
  /// Get JetBrains Mono font family with fallbacks
  static String get jetBrainsMonoFontFamily => getFontFamily(AppFonts.jetBrainsMono);
}
