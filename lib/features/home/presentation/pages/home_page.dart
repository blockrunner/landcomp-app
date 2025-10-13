/// Home page for LandComp application
///
/// This page serves as the main landing page with hero section,
/// quick start options, recent projects, and AI assistant selection.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/logo_widget.dart';
import '../../../../shared/widgets/cards/feature_card.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../projects/presentation/widgets/projects_sidebar.dart';
import '../../../projects/presentation/providers/project_provider.dart';

/// Home page widget
class HomePage extends StatelessWidget {
  /// Creates a home page
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return Scaffold(
          drawer: const ProjectsSidebar(),
          body: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(context, languageProvider),

              // Hero Section
              _buildHeroSection(context, languageProvider),

              // Quick Start Section
              _buildQuickStartSection(context, languageProvider),

              // Footer
              _buildFooter(context, languageProvider),
            ],
          ),
        );
      },
    );
  }

  /// Builds the app bar with logo and settings
  Widget _buildAppBar(BuildContext context, LanguageProvider languageProvider) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 56), // Space for menu button
              // Logo
              const SmallLogoWidget(size: 32),
              const SizedBox(width: 12),
              Text(
                'LandComp',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the hero section with main title and CTA
  Widget _buildHeroSection(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title
            Text(
              languageProvider.getString('homeHeroTitle'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              languageProvider.getString('homeHeroSubtitle'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the quick start section
  Widget _buildQuickStartSection(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.getString('quickStart'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    feature: FeatureData(
                      icon: Icons.add_circle_outline,
                      title: languageProvider.getString('newProject'),
                      description: languageProvider.getString(
                        'newProjectDescription',
                      ),
                      onTap: () async {
                        // Get ProjectProvider (now always available globally)
                        final projectProvider = context.read<ProjectProvider>();
                        // Create new project
                        await projectProvider.createNewProject();
                        // Navigate to the new project
                        if (projectProvider.currentProject != null) {
                          context.go(
                            '/chat/${projectProvider.currentProject!.id}',
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    feature: FeatureData(
                      icon: Icons.folder_open,
                      title: languageProvider.getString('myProjects'),
                      description: languageProvider.getString(
                        'myProjectsDescription',
                      ),
                      onTap: () {
                        context.go('/projects');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the footer
  Widget _buildFooter(BuildContext context, LanguageProvider languageProvider) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            Row(
              children: [
                const SmallLogoWidget(size: 24),
                const SizedBox(width: 12),
                Text(
                  'LandComp',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  languageProvider.getString('versionNumber'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              languageProvider.getString('homeFooterDescription'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
