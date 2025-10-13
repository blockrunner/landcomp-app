/// Unit tests for ProjectProvider
///
/// This file contains unit tests for the ProjectProvider class
/// to ensure proper project management functionality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:landcomp_app/features/projects/presentation/providers/project_provider.dart';
import 'package:landcomp_app/features/projects/domain/entities/project.dart';
import 'package:landcomp_app/core/storage/chat_storage.dart';
import 'package:landcomp_app/core/storage/migration_helper.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';

import 'project_provider_test.mocks.dart';

@GenerateMocks([ChatStorage, MigrationHelper, LanguageProvider])
void main() {
  group('ProjectProvider', () {
    late ProjectProvider projectProvider;
    late MockChatStorage mockChatStorage;
    late MockMigrationHelper mockMigrationHelper;
    late MockLanguageProvider mockLanguageProvider;

    setUp(() {
      mockChatStorage = MockChatStorage();
      mockMigrationHelper = MockMigrationHelper();
      mockLanguageProvider = MockLanguageProvider();

      // Setup default mock responses
      when(mockLanguageProvider.currentLocale).thenReturn(const Locale('en'));
      when(mockChatStorage.initialize()).thenAnswer((_) async {});
      when(mockChatStorage.loadAllProjects()).thenAnswer((_) async => []);
      when(
        mockMigrationHelper.isMigrationNeeded(),
      ).thenAnswer((_) async => false);
    });

    test('should initialize with empty projects list', () async {
      // Arrange
      when(mockChatStorage.loadAllProjects()).thenAnswer((_) async => []);

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();

      // Assert
      expect(projectProvider.projects, isEmpty);
      expect(projectProvider.currentProject, isNull);
      expect(projectProvider.hasProjects, isFalse);
    });

    test('should create new project successfully', () async {
      // Arrange
      when(mockChatStorage.saveProject(any)).thenAnswer((_) async {});

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();
      await projectProvider.createNewProject(title: 'Test Project');

      // Assert
      expect(projectProvider.hasProjects, isTrue);
      expect(projectProvider.currentProject?.title, equals('Test Project'));
      expect(projectProvider.projects.length, equals(1));
    });

    test('should switch between projects', () async {
      // Arrange
      final project1 = Project(
        id: '1',
        title: 'Project 1',
        agentId: 'gardener',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final project2 = Project(
        id: '2',
        title: 'Project 2',
        agentId: 'gardener',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockChatStorage.loadAllProjects(),
      ).thenAnswer((_) async => [project1, project2]);
      when(mockChatStorage.saveProject(any)).thenAnswer((_) async {});

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();
      await projectProvider.switchToProject('2');

      // Assert
      expect(projectProvider.currentProject?.id, equals('2'));
      expect(projectProvider.currentProject?.title, equals('Project 2'));
    });

    test('should delete project successfully', () async {
      // Arrange
      final project = Project(
        id: '1',
        title: 'Test Project',
        agentId: 'gardener',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockChatStorage.loadAllProjects(),
      ).thenAnswer((_) async => [project]);
      when(mockChatStorage.deleteProject(any)).thenAnswer((_) async {});
      when(mockChatStorage.saveProject(any)).thenAnswer((_) async {});

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();
      await projectProvider.deleteProject('1');

      // Assert
      expect(projectProvider.projects.length, equals(0));
      expect(projectProvider.hasProjects, isFalse);
    });

    test('should rename project successfully', () async {
      // Arrange
      final project = Project(
        id: '1',
        title: 'Old Title',
        agentId: 'gardener',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockChatStorage.loadAllProjects(),
      ).thenAnswer((_) async => [project]);
      when(mockChatStorage.loadProject(any)).thenAnswer((_) async => project);
      when(mockChatStorage.saveProject(any)).thenAnswer((_) async {});

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();
      await projectProvider.renameProject('1', 'New Title');

      // Assert
      expect(projectProvider.currentProject?.title, equals('New Title'));
    });

    test('should toggle project favorite status', () async {
      // Arrange
      final project = Project(
        id: '1',
        title: 'Test Project',
        agentId: 'gardener',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );

      when(
        mockChatStorage.loadAllProjects(),
      ).thenAnswer((_) async => [project]);
      when(mockChatStorage.saveProject(any)).thenAnswer((_) async {});

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();
      await projectProvider.toggleProjectFavorite('1');

      // Assert
      expect(projectProvider.currentProject?.isFavorite, isTrue);
    });

    test('should search projects by title', () async {
      // Arrange
      final projects = [
        Project(
          id: '1',
          title: 'Garden Design',
          agentId: 'gardener',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Project(
          id: '2',
          title: 'Backyard Project',
          agentId: 'gardener',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Project(
          id: '3',
          title: 'Front Yard',
          agentId: 'gardener',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockChatStorage.loadAllProjects()).thenAnswer((_) async => projects);

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();
      final searchResults = projectProvider.searchProjects('Garden');

      // Assert
      expect(searchResults.length, equals(1));
      expect(searchResults.first.title, equals('Garden Design'));
    });

    test('should sort projects by different criteria', () async {
      // Arrange
      final now = DateTime.now();
      final projects = [
        Project(
          id: '1',
          title: 'Z Project',
          agentId: 'gardener',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Project(
          id: '2',
          title: 'A Project',
          agentId: 'gardener',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        ),
      ];

      when(mockChatStorage.loadAllProjects()).thenAnswer((_) async => projects);

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();

      final sortedByTitle = projectProvider.getProjectsSortedBy(
        sortBy: ProjectSortBy.title,
      );
      final sortedByLastModified = projectProvider.getProjectsSortedBy(
        sortBy: ProjectSortBy.lastModified,
      );

      // Assert
      expect(sortedByTitle.first.title, equals('A Project'));
      expect(sortedByLastModified.first.title, equals('A Project'));
    });

    test('should handle migration when needed', () async {
      // Arrange
      when(
        mockMigrationHelper.isMigrationNeeded(),
      ).thenAnswer((_) async => true);
      when(
        mockMigrationHelper.performCompleteMigration(),
      ).thenAnswer((_) async => true);
      when(mockChatStorage.loadAllProjects()).thenAnswer((_) async => []);

      // Act
      projectProvider = ProjectProvider();
      await projectProvider.initialize();

      // Assert
      verify(mockMigrationHelper.performCompleteMigration()).called(1);
    });
  });
}
