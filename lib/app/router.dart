/// Application routing configuration
///
/// This file contains the routing setup using go_router
/// for navigation throughout the app.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';
import 'package:landcomp_app/features/chat/presentation/pages/chat_page.dart';
import 'package:landcomp_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:landcomp_app/features/home/presentation/pages/home_page.dart';
import 'package:landcomp_app/features/profile/presentation/pages/profile_page.dart';
import 'package:landcomp_app/features/projects/presentation/pages/projects_page.dart';
import 'package:landcomp_app/features/settings/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';

/// Application router configuration
class AppRouter {
  /// Private constructor to prevent instantiation
  AppRouter._();

  /// Main router instance
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectsPage(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => ChatProvider(),
          child: const ChatPage(),
        ),
      ),
      GoRoute(
        path: '/chat/:projectId',
        name: 'chat-project',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ChangeNotifierProvider(
            create: (context) => ChatProvider(),
            child: ChatPage(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                languageProvider.getString('pageNotFound'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.getString('pageNotFoundDescription'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: Text(languageProvider.getString('goToHome')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
