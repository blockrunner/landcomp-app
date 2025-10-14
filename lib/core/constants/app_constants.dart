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
  static const String appDescription =
      'AI-powered landscape design and gardening assistant';

  /// API Configuration
  /// Base URL for OpenAI API requests
  static const String baseUrl = 'https://api.openai.com/v1';
  /// Base URL for Google Gemini API requests
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// AI Model Configuration
  /// Default OpenAI chat/completion model identifier
  static const String openaiModel = 'gpt-4';
  /// Default Google Gemini model identifier
  static const String geminiModel = 'gemini-pro';

  /// Request Configuration
  /// HTTP request timeout in milliseconds
  static const int requestTimeout = 30000; // 30 seconds
  /// Maximum number of retry attempts for failed requests
  static const int maxRetries = 3;
  /// Maximum tokens allowed per AI request
  static const int maxTokens = 2000;

  /// Storage Configuration
  /// Hive box name for storing chat history
  static const String chatHistoryBox = 'chat_history';
  /// Hive box name for storing user settings
  static const String settingsBox = 'settings';
  /// Hive box name for caching transient data
  static const String cacheBox = 'cache';

  /// UI Configuration
  /// Default padding used across the app (in logical pixels)
  static const double defaultPadding = 16;
  /// Compact padding for tight layouts (in logical pixels)
  static const double smallPadding = 8;
  /// Spacious padding for sections (in logical pixels)
  static const double largePadding = 24;
  /// Standard border radius for components (in logical pixels)
  static const double borderRadius = 12;
  /// Smaller border radius variant (in logical pixels)
  static const double smallBorderRadius = 8;

  /// Animation Configuration
  /// Short animation duration for quick interactions
  static const Duration shortAnimation = Duration(milliseconds: 200);
  /// Medium animation duration for standard transitions
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  /// Long animation duration for emphasized transitions
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// Chat Configuration
  /// Maximum number of messages kept per chat
  static const int maxChatHistory = 100;
  /// Maximum characters allowed per outgoing message
  static const int maxMessageLength = 4000;
  /// Delay before showing typing indicator
  static const Duration typingIndicatorDelay = Duration(milliseconds: 1000);

  /// Error Messages
  /// Message shown when a network connection issue is detected
  static const String networkErrorMessage =
      'Network connection error. Please check your internet connection.';
  /// Message shown when the server returns an error
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  /// Message shown when an unhandled or unexpected error occurs
  static const String unknownErrorMessage =
      'An unknown error occurred. Please try again.';
  /// Message shown when AI provider is unavailable or failing
  static const String aiServiceErrorMessage =
      'AI service is temporarily unavailable. Please try again later.';

  /// Success Messages
  /// User-facing message shown when a message is sent successfully
  static const String messageSentMessage = 'Message sent successfully';
  /// User-facing message shown when settings are saved
  static const String settingsSavedMessage = 'Settings saved successfully';

  /// AI Agent Types
  /// Identifier for the landscape designer agent
  static const String landscapeDesignerAgent = 'landscape_designer';
  /// Identifier for the gardener agent
  static const String gardenerAgent = 'gardener';
  /// Identifier for the builder agent
  static const String builderAgent = 'builder';
  /// Identifier for the ecologist agent
  static const String ecologistAgent = 'ecologist';

  /// Supported Languages
  /// Default application language (locale code)
  static const String defaultLanguage = 'en';
  /// Russian language locale code
  static const String russianLanguage = 'ru';

  /// Feature Flags
  /// Enables offline mode features and local caching
  static const bool enableOfflineMode = true;
  /// Enables voice input features (if supported on platform)
  static const bool enableVoiceInput = false;
  /// Enables image upload features
  static const bool enableImageUpload = false;
  /// Enables analytics collection (non-PII)
  static const bool enableAnalytics = true;
}
