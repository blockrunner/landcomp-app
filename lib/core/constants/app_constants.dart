/// Application constants
/// 
/// This file contains all the application-wide constants
/// including API endpoints, app information, and configuration values.
library;

/// Application constants
class AppConstants {
  /// Private constructor to prevent instantiation
  AppConstants._();

  /// Application name
  static const String appName = 'LandComp';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Application description
  static const String appDescription = 'AI-powered landscape design and gardening assistant';

  /// API Configuration
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  /// AI Model Configuration
  static const String openaiModel = 'gpt-4';
  static const String geminiModel = 'gemini-pro';
  
  /// Request Configuration
  static const int requestTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
  static const int maxTokens = 2000;
  
  /// Storage Configuration
  static const String chatHistoryBox = 'chat_history';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  
  /// UI Configuration
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
  static const double borderRadius = 12;
  static const double smallBorderRadius = 8;
  
  /// Animation Configuration
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  /// Chat Configuration
  static const int maxChatHistory = 100;
  static const int maxMessageLength = 4000;
  static const Duration typingIndicatorDelay = Duration(milliseconds: 1000);
  
  /// Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  static const String aiServiceErrorMessage = 'AI service is temporarily unavailable. Please try again later.';
  
  /// Success Messages
  static const String messageSentMessage = 'Message sent successfully';
  static const String settingsSavedMessage = 'Settings saved successfully';
  
  /// AI Agent Types
  static const String landscapeDesignerAgent = 'landscape_designer';
  static const String gardenerAgent = 'gardener';
  static const String builderAgent = 'builder';
  static const String ecologistAgent = 'ecologist';
  
  /// Supported Languages
  static const String defaultLanguage = 'en';
  static const String russianLanguage = 'ru';
  
  /// Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableVoiceInput = false;
  static const bool enableImageUpload = false;
  static const bool enableAnalytics = true;
}
