/// Test script for theme switching functionality
/// 
/// This script tests the ThemeProvider functionality
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landcomp_app/core/theme/theme_provider.dart';
import 'package:landcomp_app/app/theme.dart';

/// Test widget for theme switching
class ThemeSwitchTest extends StatelessWidget {
  const ThemeSwitchTest({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Theme Switch Test',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Theme Switch Test'),
                actions: [
                  IconButton(
                    icon: Icon(
                      themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Current Theme: ${themeProvider.themeModeString}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        themeProvider.setThemeMode(ThemeMode.light);
                      },
                      child: const Text('Light Theme'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        themeProvider.setThemeMode(ThemeMode.dark);
                      },
                      child: const Text('Dark Theme'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        themeProvider.setThemeMode(ThemeMode.system);
                      },
                      child: const Text('System Theme'),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Test Card',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This card should change appearance based on the selected theme.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Main function for testing
void main() {
  runApp(const ThemeSwitchTest());
}
