/// Test script for localization fixes
/// 
/// This script tests the localization fixes we made
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';
import 'package:landcomp_app/core/theme/theme_provider.dart';
import 'package:landcomp_app/app/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const LocalizationTestApp(),
    ),
  );
}

class LocalizationTestApp extends StatelessWidget {
  const LocalizationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return MaterialApp(
          title: 'Localization Test',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const LocalizationTestPage(),
        );
      },
    );
  }
}

class LocalizationTestPage extends StatelessWidget {
  const LocalizationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localization Test'),
        actions: [
          Consumer2<LanguageProvider, ThemeProvider>(
            builder: (context, languageProvider, themeProvider, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language toggle
                  IconButton(
                    icon: Text(
                      languageProvider.isRussian ? '🇷🇺' : '🇺🇸',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      languageProvider.toggleLanguage();
                    },
                  ),
                  // Theme toggle
                  IconButton(
                    icon: Icon(
                      themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Test 1: Message hint
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test 1: Message Hint',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: languageProvider.getString('messageHint'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expected: ${languageProvider.isRussian ? "Спросите о ландшафтном дизайне..." : "Ask about landscape design..."}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Test 2: Theme names
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test 2: Theme Names',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Light: ${languageProvider.getString('light')}'),
                        Text('Dark: ${languageProvider.getString('dark')}'),
                        Text('System: ${languageProvider.getString('system')}'),
                        const SizedBox(height: 8),
                        Text(
                          'Current theme: ${_getLocalizedThemeName(themeProvider.themeModeString, languageProvider)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Test 3: Language switch visibility
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test 3: Language Switch Visibility',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              languageProvider.isRussian ? '🇷🇺' : '🇺🇸',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.isRussian ? 'RU' : 'EN',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This text should be visible in both light and dark themes',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Get localized theme name
  String _getLocalizedThemeName(String theme, LanguageProvider languageProvider) {
    switch (theme) {
      case 'light':
        return languageProvider.getString('light');
      case 'dark':
        return languageProvider.getString('dark');
      case 'system':
        return languageProvider.getString('system');
      default:
        return languageProvider.getString('system');
    }
  }
}
