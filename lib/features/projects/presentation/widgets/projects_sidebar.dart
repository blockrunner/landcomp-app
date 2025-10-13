/// Projects sidebar widget
///
/// This widget displays a sidebar with navigation menu and projects list.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../shared/widgets/logo_widget.dart';
import 'project_list_item.dart';
import 'new_project_dialog.dart';
import 'rename_project_dialog.dart';

/// Projects sidebar widget
class ProjectsSidebar extends StatefulWidget {
  /// Creates a projects sidebar
  const ProjectsSidebar({super.key});

  @override
  State<ProjectsSidebar> createState() => _ProjectsSidebarState();
}

class _ProjectsSidebarState extends State<ProjectsSidebar> {
  bool _projectsExpanded = true;

  @override
  Widget build(BuildContext context) {
    // ProjectProvider is now always available globally
    final projectProvider = context.watch<ProjectProvider>();

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Drawer(
          child: Column(
            children: [
              // Header with logo and app name
              _buildHeader(context, languageProvider),

              // Home navigation item
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                title: languageProvider.getString('home'),
                onTap: () {
                  context.go('/');
                  Navigator.of(context).pop();
                },
              ),

              // Projects section (expandable)
              _buildProjectsSection(context, projectProvider, languageProvider),

              const Divider(height: 1),

              // Other navigation items
              _buildOtherNavigationMenu(context, languageProvider),

              const Spacer(),

              const Divider(height: 1),

              // Footer with version info
              _buildFooter(context, languageProvider),
            ],
          ),
        );
      },
    );
  }

  /// Builds the sidebar header
  Widget _buildHeader(BuildContext context, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const SmallLogoWidget(size: 32),
            const SizedBox(width: 12),
            Text(
              languageProvider.getString('appName'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds other navigation menu items (catalog, planner, profile, settings)
  Widget _buildOtherNavigationMenu(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    return Column(
      children: [
        _buildNavItem(
          context,
          icon: Icons.nature_outlined,
          title: languageProvider.getString('catalog'),
          subtitle: languageProvider.getString('comingSoon'),
          enabled: false,
          onTap: () {
            // TODO: Implement catalog
          },
        ),
        _buildNavItem(
          context,
          icon: Icons.grid_on_outlined,
          title: languageProvider.getString('planner'),
          subtitle: languageProvider.getString('comingSoon'),
          enabled: false,
          onTap: () {
            // TODO: Implement planner
          },
        ),
        _buildNavItem(
          context,
          icon: Icons.person_outline,
          title: languageProvider.getString('profile'),
          onTap: () {
            context.go('/profile');
            Navigator.of(context).pop();
          },
        ),
        _buildNavItem(
          context,
          icon: Icons.settings_outlined,
          title: languageProvider.getString('settings'),
          onTap: () {
            context.go('/settings');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  /// Builds a navigation item
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }

  /// Builds the projects section
  Widget _buildProjectsSection(
    BuildContext context,
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    return Column(
      children: [
        ExpansionTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(languageProvider.getString('projects')),
          subtitle: Text(
            '${projectProvider.projectCount} ${languageProvider.getString('projects').toLowerCase()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          initiallyExpanded: _projectsExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _projectsExpanded = expanded;
            });
          },
          children: [
            // New project button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showNewProjectDialog(
                    context,
                    projectProvider,
                    languageProvider,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(languageProvider.getString('newProject')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Projects list
            if (projectProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )
            else if (!projectProvider.hasProjects)
              _buildEmptyState(context, languageProvider)
            else
              _buildProjectsList(context, projectProvider, languageProvider),
          ],
        ),
      ],
    );
  }

  /// Builds the projects list
  Widget _buildProjectsList(
    BuildContext context,
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: projectProvider.projects.length,
        itemBuilder: (context, index) {
          final project = projectProvider.projects[index];
          final isCurrentProject =
              projectProvider.currentProject?.id == project.id;

          return ProjectListItem(
            project: project,
            isActive: isCurrentProject,
            onTap: () => _switchToProject(context, projectProvider, project),
            onLongPress: () => _showProjectOptions(
              context,
              projectProvider,
              project,
              languageProvider,
            ),
          );
        },
      ),
    );
  }

  /// Builds the empty state when no projects exist
  Widget _buildEmptyState(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            languageProvider.getString('projectsEmpty'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the sidebar footer
  Widget _buildFooter(BuildContext context, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              languageProvider.getString('versionNumber'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the new project dialog
  void _showNewProjectDialog(
    BuildContext context,
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => NewProjectDialog(
        onProjectCreated: (title) {
          projectProvider.createNewProject(title: title);
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Close sidebar
        },
      ),
    );
  }

  /// Switches to the selected project
  void _switchToProject(
    BuildContext context,
    ProjectProvider projectProvider,
    Project project,
  ) {
    projectProvider.switchToProject(project.id);
    Navigator.of(context).pop(); // Close sidebar
    // Navigate to the project's chat page
    context.go('/chat/${project.id}');
  }

  /// Shows project options menu
  void _showProjectOptions(
    BuildContext context,
    ProjectProvider projectProvider,
    Project project,
    LanguageProvider languageProvider,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildProjectOptionsSheet(
        context,
        projectProvider,
        project,
        languageProvider,
      ),
    );
  }

  /// Builds the project options bottom sheet
  Widget _buildProjectOptionsSheet(
    BuildContext context,
    ProjectProvider projectProvider,
    Project project,
    LanguageProvider languageProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            project.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Options
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(languageProvider.getString('renameProject')),
            onTap: () {
              Navigator.of(context).pop();
              _showRenameDialog(
                context,
                projectProvider,
                project,
                languageProvider,
              );
            },
          ),

          ListTile(
            leading: Icon(project.isFavorite ? Icons.star : Icons.star_border),
            title: Text(
              project.isFavorite
                  ? languageProvider.getString('removeFromFavorites')
                  : languageProvider.getString('markAsFavorite'),
            ),
            onTap: () {
              projectProvider.toggleProjectFavorite(project.id);
              Navigator.of(context).pop();
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(
              languageProvider.getString('deleteProject'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(
                context,
                projectProvider,
                project,
                languageProvider,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Shows the rename project dialog
  void _showRenameDialog(
    BuildContext context,
    ProjectProvider projectProvider,
    Project project,
    LanguageProvider languageProvider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => RenameProjectDialog(
        currentTitle: project.title,
        onRenamed: (newTitle) {
          projectProvider.renameProject(project.id, newTitle);
        },
      ),
    );
  }

  /// Shows the delete confirmation dialog
  void _showDeleteConfirmation(
    BuildContext context,
    ProjectProvider projectProvider,
    Project project,
    LanguageProvider languageProvider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.getString('deleteProject')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languageProvider.getString('deleteProjectConfirm')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${languageProvider.getString('messageCount')}: ${project.messageCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.getString('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              projectProvider.deleteProject(project.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(languageProvider.getString('delete')),
          ),
        ],
      ),
    );
  }
}
