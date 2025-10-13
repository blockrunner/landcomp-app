/// Projects page for managing all projects
/// 
/// This page displays a full-screen list of all projects with
/// search, filter, and management capabilities.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_list_item.dart';
import '../widgets/new_project_dialog.dart';
import '../widgets/projects_sidebar.dart';
import '../../../../core/localization/language_provider.dart';

/// Projects page widget
class ProjectsPage extends StatefulWidget {
  /// Creates a projects page
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final _searchController = TextEditingController();
  ProjectSortBy _currentSortBy = ProjectSortBy.lastModified;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProjectProvider, LanguageProvider>(
      builder: (context, projectProvider, languageProvider, child) {
        return Scaffold(
          appBar: _buildAppBar(context, projectProvider, languageProvider),
          drawer: const ProjectsSidebar(),
          body: _buildBody(context, projectProvider, languageProvider),
        );
      },
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    return AppBar(
      title: Text(languageProvider.getString('projects')),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        // New project button
        TextButton.icon(
          onPressed: () => _showNewProjectDialog(context, projectProvider, languageProvider),
          icon: const Icon(Icons.add),
          label: Text(languageProvider.getString('newProject')),
        ),
        const SizedBox(width: 8),
        // Sort button
        PopupMenuButton<ProjectSortBy>(
          icon: const Icon(Icons.sort),
          tooltip: languageProvider.getString('sortBy'),
          onSelected: (sortBy) {
            setState(() {
              _currentSortBy = sortBy;
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ProjectSortBy.lastModified,
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: _currentSortBy == ProjectSortBy.lastModified
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(languageProvider.getString('lastModified')),
                ],
              ),
            ),
            PopupMenuItem(
              value: ProjectSortBy.created,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: _currentSortBy == ProjectSortBy.created
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(languageProvider.getString('created')),
                ],
              ),
            ),
            PopupMenuItem(
              value: ProjectSortBy.title,
              child: Row(
                children: [
                  Icon(
                    Icons.sort_by_alpha,
                    size: 20,
                    color: _currentSortBy == ProjectSortBy.title
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(languageProvider.getString('projectTitle')),
                ],
              ),
            ),
            PopupMenuItem(
              value: ProjectSortBy.favorites,
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 20,
                    color: _currentSortBy == ProjectSortBy.favorites
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(languageProvider.getString('favorites')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the main body
  Widget _buildBody(
    BuildContext context,
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(context, languageProvider),
        
        // Projects list
        Expanded(
          child: _buildProjectsList(context, projectProvider, languageProvider),
        ),
      ],
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar(BuildContext context, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: languageProvider.getString('searchProjects'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// Builds the projects list
  Widget _buildProjectsList(
    BuildContext context,
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    if (projectProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Get filtered and sorted projects
    List<Project> projects = _searchQuery.isNotEmpty
        ? projectProvider.searchProjects(_searchQuery)
        : projectProvider.getProjectsSortedBy(sortBy: _currentSortBy);

    if (projects.isEmpty) {
      return _buildEmptyState(context, languageProvider, _searchQuery.isNotEmpty);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final isCurrentProject = projectProvider.currentProject?.id == project.id;
        
        return ProjectListItem(
          project: project,
          isActive: isCurrentProject,
          onTap: () => _openProject(context, project),
          onLongPress: () => _showProjectOptions(context, projectProvider, project, languageProvider),
        );
      },
    );
  }

  /// Builds the empty state
  Widget _buildEmptyState(BuildContext context, LanguageProvider languageProvider, bool isSearch) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearch ? Icons.search_off : Icons.folder_open_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isSearch 
                ? languageProvider.getString('noProjectsFound')
                : languageProvider.getString('projectsEmpty'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                ? 'Try a different search term'
                : languageProvider.getString('createFirstProject'),
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

  /// Opens a project in chat
  void _openProject(BuildContext context, Project project) {
    context.go('/chat/${project.id}');
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
        },
      ),
    );
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Open project
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: Text('Open Project'),
            onTap: () {
              Navigator.of(context).pop();
              _openProject(context, project);
            },
          ),
          
          // Rename
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(languageProvider.getString('renameProject')),
            onTap: () {
              Navigator.of(context).pop();
              _showRenameDialog(context, projectProvider, project, languageProvider);
            },
          ),
          
          // Toggle favorite
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
          
          // Delete
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(
              languageProvider.getString('deleteProject'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, projectProvider, project, languageProvider);
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
    final controller = TextEditingController(text: project.title);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.getString('renameProject')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: languageProvider.getString('projectTitle'),
            hintText: languageProvider.getString('projectTitleHint'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.getString('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != project.title) {
                projectProvider.renameProject(project.id, newTitle);
              }
              Navigator.of(context).pop();
            },
            child: Text(languageProvider.getString('save')),
          ),
        ],
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
