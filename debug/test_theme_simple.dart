/// Simple test for theme switching
/// 
/// This script tests the ThemeProvider functionality in isolation
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landcomp_app/core/theme/theme_provider.dart';
import 'package:landcomp_app/app/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const ThemeTestApp(),
    ),
  );
}

class ThemeTestApp extends StatelessWidget {
  const ThemeTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Theme Test',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const ThemeTestPage(),
        );
      },
    );
  }
}

class ThemeTestPage extends StatelessWidget {
  const ThemeTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Switch Test'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Text(
                  'Current Theme: ${themeProvider.themeModeString}',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
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
                  ],
                );
              },
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
    );
  }
}
