/// Settings page for application configuration
///
/// This page allows users to configure various app settings
/// including AI provider, theme, language, and other preferences.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:landcomp_app/core/localization/language_provider.dart';
import 'package:landcomp_app/core/theme/theme_provider.dart';
import '../../../projects/presentation/widgets/projects_sidebar.dart';

/// Settings page widget
class SettingsPage extends StatefulWidget {
  /// Creates a settings page
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedAIProvider = 'openai';
  bool _enableNotifications = true;
  bool _enableOfflineMode = true;

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(languageProvider.getString('settingsTitle')),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          drawer: const ProjectsSidebar(),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // AI Provider Section
              _buildSection(
                context: context,
                languageProvider: languageProvider,
                title: languageProvider.getString('aiProvider'),
                children: [
                  RadioListTile<String>(
                    title: Text(languageProvider.getString('openaiGpt4')),
                    subtitle: Text(
                      languageProvider.getString('openaiGpt4Subtitle'),
                    ),
                    value: 'openai',
                    groupValue: _selectedAIProvider,
                    onChanged: (value) {
                      setState(() {
                        _selectedAIProvider = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(languageProvider.getString('googleGemini')),
                    subtitle: Text(
                      languageProvider.getString('googleGeminiSubtitle'),
                    ),
                    value: 'gemini',
                    groupValue: _selectedAIProvider,
                    onChanged: (value) {
                      setState(() {
                        _selectedAIProvider = value!;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Appearance Section
              _buildSection(
                context: context,
                languageProvider: languageProvider,
                title: languageProvider.getString('appearance'),
                children: [
                  ListTile(
                    title: Text(languageProvider.getString('language')),
                    subtitle: Text(languageProvider.getLanguageDisplayName()),
                    trailing: PopupMenuButton<String>(
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            languageProvider.isRussian ? '🇷🇺' : '🇺🇸',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            languageProvider.isRussian ? 'RU' : 'EN',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                      onSelected: (String languageCode) {
                        languageProvider.setLanguage(Locale(languageCode));
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'ru',
                          child: Row(
                            children: [
                              const Text(
                                '🇷🇺',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(languageProvider.getString('russian')),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'en',
                          child: Row(
                            children: [
                              const Text(
                                '🇺🇸',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(languageProvider.getString('english')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(languageProvider.getString('theme')),
                    subtitle: Text(
                      _getLocalizedThemeName(
                        themeProvider.themeModeString,
                        languageProvider,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showThemeDialog(
                        context,
                        languageProvider,
                        themeProvider,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Features Section
              _buildSection(
                context: context,
                languageProvider: languageProvider,
                title: languageProvider.getString('features'),
                children: [
                  SwitchListTile(
                    title: Text(languageProvider.getString('notifications')),
                    subtitle: Text(
                      languageProvider.getString('notificationsSubtitle'),
                    ),
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _enableNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(languageProvider.getString('offlineMode')),
                    subtitle: Text(
                      languageProvider.getString('offlineModeSubtitle'),
                    ),
                    value: _enableOfflineMode,
                    onChanged: (value) {
                      setState(() {
                        _enableOfflineMode = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSection(
                context: context,
                languageProvider: languageProvider,
                title: languageProvider.getString('about'),
                children: [
                  ListTile(
                    title: Text(languageProvider.getString('version')),
                    subtitle: const Text('1.0.0'),
                    trailing: const Icon(Icons.info_outline),
                  ),
                  ListTile(
                    title: Text(languageProvider.getString('privacyPolicy')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Open privacy policy
                    },
                  ),
                  ListTile(
                    title: Text(languageProvider.getString('termsOfService')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Open terms of service
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a settings section
  Widget _buildSection({
    required BuildContext context,
    required LanguageProvider languageProvider,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Get localized theme name
  String _getLocalizedThemeName(
    String theme,
    LanguageProvider languageProvider,
  ) {
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

  /// Shows theme selection dialog
  void _showThemeDialog(
    BuildContext context,
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.getString('theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(languageProvider.getString('light')),
              value: 'light',
              groupValue: themeProvider.themeModeString,
              onChanged: (value) {
                themeProvider.setThemeModeFromString(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(languageProvider.getString('dark')),
              value: 'dark',
              groupValue: themeProvider.themeModeString,
              onChanged: (value) {
                themeProvider.setThemeModeFromString(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(languageProvider.getString('system')),
              value: 'system',
              groupValue: themeProvider.themeModeString,
              onChanged: (value) {
                themeProvider.setThemeModeFromString(value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
