/// Main application widget for Landscape AI App
///
/// This file contains the root application widget that sets up the
/// overall app structure, theme, and routing.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:landcomp_app/app/router.dart';
import 'package:landcomp_app/app/theme.dart';
import 'package:landcomp_app/core/config/web_config.dart';
import 'package:landcomp_app/core/constants/app_constants.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/core/storage/chat_storage.dart';
import 'package:landcomp_app/core/theme/theme_provider.dart';
import 'package:landcomp_app/di/injection.dart';
import 'package:provider/provider.dart';

/// Main application widget
class LandscapeAIApp extends StatelessWidget {
  /// Creates the main application widget
  const LandscapeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp.router(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.currentLocale,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.noScaling),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

/// Application initialization
class AppInitializer {
  /// Initializes the application
  static Future<void> initialize() async {
    // Initialize web-specific configurations
    await WebConfig.initialize();

    // Load environment variables
    try {
      await dotenv.load();
      debugPrint('✅ Environment variables loaded successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to load .env file: $e');
      // Continue without .env file
    }

    // Initialize Hive
    await Hive.initFlutter();

    // Initialize dependency injection
    await configureDependencies();

    // Initialize AI Service
    try {
      await AIService.instance.initialize();
      debugPrint('✅ AIService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize AIService: $e');
      // Don't throw here to allow app to start even if AI service fails
    }

    // Initialize Chat Storage
    try {
      await ChatStorage.instance.initialize();
      debugPrint('✅ ChatStorage initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize ChatStorage: $e');
      // Don't throw here to allow app to start even if chat storage fails
    }

    // Initialize other services
    // TODO(developer): Add other initialization logic
  }
}
