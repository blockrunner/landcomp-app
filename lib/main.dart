/// Main entry point for the Landscape AI App
///
/// This file initializes the application and sets up the main app widget.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:landcomp_app/app/app.dart';
import 'package:landcomp_app/core/theme/theme_provider.dart';
import 'package:landcomp_app/features/projects/presentation/providers/project_provider.dart';

/// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the application
  await AppInitializer.initialize();

  // Initialize providers
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final projectProvider = ProjectProvider();
  await projectProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: projectProvider),
      ],
      child: const LandscapeAIApp(),
    ),
  );
}
