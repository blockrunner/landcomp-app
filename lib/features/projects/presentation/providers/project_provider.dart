/// Project provider for managing project state
///
/// This provider manages the projects list, current project,
/// and project operations like creation, switching, and deletion.
library;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/project.dart';
import '../../../../core/storage/chat_storage.dart';
import '../../../../core/storage/migration_helper.dart';
import '../../../../core/localization/language_provider.dart';

/// Project provider for state management
class ProjectProvider extends ChangeNotifier {
  ProjectProvider() {
    _initializeProvider();
  }

  final _uuid = const Uuid();
  final _chatStorage = ChatStorage.instance;
  final _migrationHelper = MigrationHelper.instance;

  // Current state
  Project? _currentProject;
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;
  LanguageProvider? _languageProvider;
  bool _isInitialized = false;

  // Getters
  Project? get currentProject => _currentProject;
  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProjects => _projects.isNotEmpty;
  bool get isInitialized => _isInitialized;
  int get projectCount => _projects.length;

  /// Initialize the provider
  Future<void> _initializeProvider() async {
    try {
      // Initialize chat storage
      await _chatStorage.initialize();

      // Check if migration is needed and perform it
      if (await _migrationHelper.isMigrationNeeded()) {
        print('🔄 Migration needed, performing migration...');
        await _migrationHelper.performCompleteMigration();
      }

      // Load existing projects
      await _loadProjects();

      // Create new project if none exist
      if (_projects.isEmpty) {
        await createNewProject();
      } else {
        // Use the most recent project
        _currentProject = _projects.first;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error initializing ProjectProvider: $e');
      _setError('Failed to initialize projects: ${e.toString()}');
    }
  }

  /// Load projects from storage
  Future<void> _loadProjects() async {
    try {
      _projects = await _chatStorage.loadAllProjects();
      print('📂 Loaded ${_projects.length} projects from storage');
    } catch (e) {
      print('❌ Error loading projects: $e');
      _projects = [];
    }
  }

  /// Set language provider for localization
  void setLanguageProvider(LanguageProvider languageProvider) {
    if (_languageProvider != languageProvider) {
      _languageProvider = languageProvider;
      // Don't notify listeners here to avoid setState during build
    }
  }

  /// Create a new project
  Future<void> createNewProject({String? title}) async {
    try {
      _setLoading(true);
      _clearError();

      final projectId = _uuid.v4();
      final projectTitle = title ?? _getDefaultProjectTitle();

      final project = Project(
        id: projectId,
        title: projectTitle,
        // agentId: 'gardener', // Default to gardener agent
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: const [],
        isFavorite: false,
      );

      // Save to storage
      await _chatStorage.saveProject(project);

      // Add to local list
      _projects.insert(0, project);
      _currentProject = project;

      print('✅ Created new project: ${project.title}');
      notifyListeners();
    } catch (e) {
      print('❌ Error creating project: $e');
      _setError('Failed to create project: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Switch to a different project
  Future<void> switchToProject(String projectId) async {
    try {
      final project = _projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );

      _currentProject = project;
      print('🔄 Switched to project: ${project.title}');
      notifyListeners();
    } catch (e) {
      print('❌ Error switching to project: $e');
      _setError('Failed to switch project: ${e.toString()}');
    }
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      _setLoading(true);
      _clearError();

      // Remove from storage
      await _chatStorage.deleteProject(projectId);

      // Remove from local list
      _projects.removeWhere((p) => p.id == projectId);

      // If we deleted the current project, switch to another or create new
      if (_currentProject?.id == projectId) {
        if (_projects.isNotEmpty) {
          _currentProject = _projects.first;
        } else {
          await createNewProject();
        }
      }

      print('🗑️ Deleted project: $projectId');
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting project: $e');
      _setError('Failed to delete project: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Rename a project
  Future<void> renameProject(String projectId, String newTitle) async {
    try {
      _setLoading(true);
      _clearError();

      // Update in storage
      await _chatStorage.updateProjectTitle(projectId, newTitle);

      // Update in local list
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex >= 0) {
        _projects[projectIndex] = _projects[projectIndex].updateTitle(newTitle);

        // Update current project if it's the one being renamed
        if (_currentProject?.id == projectId) {
          _currentProject = _projects[projectIndex];
        }
      }

      print('📝 Renamed project: $projectId -> $newTitle');
      notifyListeners();
    } catch (e) {
      print('❌ Error renaming project: $e');
      _setError('Failed to rename project: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle favorite status of a project
  Future<void> toggleProjectFavorite(String projectId) async {
    try {
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex >= 0) {
        final updatedProject = _projects[projectIndex].toggleFavorite();
        _projects[projectIndex] = updatedProject;

        // Update current project if it's the one being toggled
        if (_currentProject?.id == projectId) {
          _currentProject = updatedProject;
        }

        // Save to storage
        await _chatStorage.saveProject(updatedProject);

        print('⭐ Toggled favorite for project: ${updatedProject.title}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error toggling project favorite: $e');
      _setError('Failed to toggle favorite: ${e.toString()}');
    }
  }

  /// Update current project with new message
  Future<void> updateCurrentProjectWithMessage(Project updatedProject) async {
    try {
      if (_currentProject?.id != updatedProject.id) return;

      _currentProject = updatedProject;

      // Update in local list
      final projectIndex = _projects.indexWhere(
        (p) => p.id == updatedProject.id,
      );
      if (projectIndex >= 0) {
        _projects[projectIndex] = updatedProject;
      } else {
        _projects.insert(0, updatedProject);
      }

      // Save to storage
      await _chatStorage.saveProject(updatedProject);

      notifyListeners();
    } catch (e) {
      print('❌ Error updating project with message: $e');
      _setError('Failed to update project: ${e.toString()}');
    }
  }

  /// Get projects sorted by different criteria
  List<Project> getProjectsSortedBy({
    ProjectSortBy sortBy = ProjectSortBy.lastModified,
  }) {
    final sortedProjects = List<Project>.from(_projects);

    switch (sortBy) {
      case ProjectSortBy.lastModified:
        sortedProjects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case ProjectSortBy.created:
        sortedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProjectSortBy.title:
        sortedProjects.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case ProjectSortBy.favorites:
        sortedProjects.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }

    return sortedProjects;
  }

  /// Search projects by title or content
  List<Project> searchProjects(String query) {
    if (query.trim().isEmpty) return _projects;

    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) {
      return project.title.toLowerCase().contains(lowercaseQuery) ||
          (project.previewText?.toLowerCase().contains(lowercaseQuery) ??
              false);
    }).toList();
  }

  /// Get favorite projects
  List<Project> get favoriteProjects {
    return _projects.where((p) => p.isFavorite).toList();
  }

  /// Get recent projects (last 5)
  List<Project> get recentProjects {
    return getProjectsSortedBy(
      sortBy: ProjectSortBy.lastModified,
    ).take(5).toList();
  }

  /// Clear all projects
  Future<void> clearAllProjects() async {
    try {
      _setLoading(true);
      _clearError();

      await _chatStorage.clearAllProjects();
      _projects.clear();
      await createNewProject();

      print('🧹 Cleared all projects');
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing projects: $e');
      _setError('Failed to clear projects: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get default project title
  String _getDefaultProjectTitle() {
    if (_languageProvider != null) {
      final isRussian = _languageProvider!.currentLocale.languageCode == 'ru';
      return isRussian ? 'Новый проект' : 'New Project';
    }
    return 'New Project';
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Initialize the provider (public method)
  Future<void> initialize() async {
    await _initializeProvider();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Project sorting options
enum ProjectSortBy { lastModified, created, title, favorites }
