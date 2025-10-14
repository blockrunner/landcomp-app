/// Web-specific configuration for Flutter web
///
/// This file contains web-specific configurations including CanvasKit setup,
/// CSP handling, and other web platform optimizations.
library;

import 'package:flutter/foundation.dart';

/// Web configuration utilities
class WebConfig {
  WebConfig._();

  /// Initialize web-specific configurations
  static Future<void> initialize() async {
    if (kIsWeb) {
      await _configureCanvasKit();
      _configureWebSecurity();
    }
  }

  /// Configure CanvasKit for web
  static Future<void> _configureCanvasKit() async {
    // Set CanvasKit configuration
    // This helps with CanvasKit loading and fallback behavior
    if (kDebugMode) {
      print('🌐 Configuring CanvasKit for web platform');
    }
    
    // Set up CanvasKit fallback handling
    // The fallback script in web/canvaskit_fallback.js will handle this
  }

  /// Configure web security settings
  static void _configureWebSecurity() {
    if (kDebugMode) {
      print('🔒 Configuring web security settings');
    }
    
    // Additional web security configurations can be added here
    // For now, the CSP is handled in web/index.html
  }

  /// Check if CanvasKit fallback is enabled
  static bool get isCanvasKitFallbackEnabled {
    if (!kIsWeb) return false;
    
    // Check if the fallback flag is set by the fallback script
    return true; // Always return true for web to enable fallback handling
  }

  /// Get CanvasKit configuration for Flutter web
  static Map<String, dynamic> getCanvasKitConfig() {
    return {
      'renderer': 'auto', // Let Flutter decide between CanvasKit and HTML
      'fallback': true,   // Enable fallback to HTML renderer
    };
  }
}
