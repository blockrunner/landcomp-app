/// Environment configuration for API keys and proxy settings
/// 
/// This file manages environment variables for AI services,
/// proxy configuration, and fallback mechanisms.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class
class EnvConfig {
  EnvConfig._();

  // Helper method to get environment variable
  static String _getEnvVar(String key) {
    try {
      // For web platform, use dotenv
      if (kIsWeb) {
        return dotenv.env[key] ?? '';
      }
      
      // For mobile/desktop, try dotenv first, then Platform.environment
      if (dotenv.env.containsKey(key)) {
        return dotenv.env[key] ?? '';
      }
      
      // Fallback to Platform.environment (for mobile/desktop)
      return Platform.environment[key] ?? '';
    } catch (e) {
      // If dotenv is not loaded and we're on web, return empty
      if (kIsWeb) {
        return '';
      }
      // For mobile/desktop, try Platform.environment
      try {
        return Platform.environment[key] ?? '';
      } catch (e) {
        return '';
      }
    }
  }

  // OpenAI Configuration
  static String get openaiApiKey => _getEnvVar('OPENAI_API_KEY');

  // Google API Configuration
  static String get googleApiKey => _getEnvVar('GOOGLE_API_KEY');
  
  static List<String> get googleApiKeysFallback {
    final fallbackKeys = _getEnvVar('GOOGLE_API_KEYS_FALLBACK');
    return fallbackKeys.split(',').where((key) => key.isNotEmpty).toList();
  }

  // Proxy Configuration
  static String get allProxy => _getEnvVar('ALL_PROXY');
  
  static List<String> get backupProxies {
    final backupProxies = _getEnvVar('BACKUP_PROXIES');
    return backupProxies.split(',').where((proxy) => proxy.isNotEmpty).toList();
  }

  // Yandex Cloud Configuration (if needed)
  static String get ycApiKeyId => _getEnvVar('YC_API_KEY_ID');
  
  static String get ycApiKey => _getEnvVar('YC_API_KEY');
  
  static String get ycFolderId => _getEnvVar('YC_FOLDER_ID');

  // Other API Keys
  static String get stabilityApiKey => _getEnvVar('STABILITY_API_KEY');
  
  static String get huggingfaceApiKey => _getEnvVar('HUGGINGFACE_API_KEY');

  // Validation
  static bool get isOpenAIConfigured => openaiApiKey.isNotEmpty;
  static bool get isGoogleConfigured => googleApiKey.isNotEmpty;
  static bool get isProxyConfigured => allProxy.isNotEmpty;
  static bool get hasBackupProxies => backupProxies.isNotEmpty;
  static bool get hasGoogleFallbackKeys => googleApiKeysFallback.isNotEmpty;

  /// Get current proxy configuration
  static String getCurrentProxy() {
    if (allProxy.isNotEmpty) {
      return allProxy;
    }
    if (backupProxies.isNotEmpty) {
      return backupProxies.first;
    }
    return '';
  }

  /// Get next backup proxy
  static String? getNextBackupProxy(String currentProxy) {
    final currentIndex = backupProxies.indexOf(currentProxy);
    if (currentIndex >= 0 && currentIndex < backupProxies.length - 1) {
      return backupProxies[currentIndex + 1];
    }
    return null;
  }

  /// Get next Google API key
  static String? getNextGoogleApiKey(String currentKey) {
    final fallbackKeys = googleApiKeysFallback;
    if (fallbackKeys.isEmpty) return null;
    
    final currentIndex = fallbackKeys.indexOf(currentKey);
    if (currentIndex >= 0 && currentIndex < fallbackKeys.length - 1) {
      return fallbackKeys[currentIndex + 1];
    }
    return fallbackKeys.isNotEmpty ? fallbackKeys.first : null;
  }

  /// Validate all required configurations
  static Map<String, bool> validateConfiguration() {
    return {
      'openai_configured': isOpenAIConfigured,
      'google_configured': isGoogleConfigured,
      'proxy_configured': isProxyConfigured,
      'has_backup_proxies': hasBackupProxies,
      'has_google_fallback': hasGoogleFallbackKeys,
    };
  }
}
