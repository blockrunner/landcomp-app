/// Widget tests for ProjectsSidebar
/// 
/// This file contains widget tests for the ProjectsSidebar widget
/// to ensure proper UI functionality and user interactions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:landcomp_app/features/projects/presentation/widgets/projects_sidebar.dart';
import 'package:landcomp_app/features/projects/presentation/providers/project_provider.dart';
import 'package:landcomp_app/features/projects/domain/entities/project.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';

import 'projects_sidebar_test.mocks.dart';

@GenerateMocks([ProjectProvider, LanguageProvider])
void main() {
  group('ProjectsSidebar', () {
    late MockProjectProvider mockProjectProvider;
    late MockLanguageProvider mockLanguageProvider;

    setUp(() {
      mockProjectProvider = MockProjectProvider();
      mockLanguageProvider = MockLanguageProvider();
      
      // Setup default mock responses
      when(mockLanguageProvider.currentLocale).thenReturn(const Locale('en'));
      when(mockLanguageProvider.getString(any)).thenAnswer((invocation) {
        final key = invocation.positionalArguments[0] as String;
        return key; // Return the key as the string for testing
      });
      when(mockProjectProvider.projects).thenReturn([]);
      when(mockProjectProvider.isLoading).thenReturn(false);
      when(mockProjectProvider.hasProjects).thenReturn(false);
      when(mockProjectProvider.projectCount).thenReturn(0);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ProjectProvider>.value(value: mockProjectProvider),
            ChangeNotifierProvider<LanguageProvider>.value(value: mockLanguageProvider),
          ],
          child: const Scaffold(
            drawer: ProjectsSidebar(),
          ),
        ),
      );
    }

    testWidgets('should display empty state when no projects exist', (WidgetTester tester) async {
      // Arrange
      when(mockProjectProvider.hasProjects).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('projectsEmpty'), findsOneWidget);
      expect(find.text('createFirstProject'), findsOneWidget);
    });

    testWidgets('should display projects list when projects exist', (WidgetTester tester) async {
      // Arrange
      final projects = [
        Project(
          id: '1',
          title: 'Test Project 1',
          agentId: 'gardener',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Project(
          id: '2',
          title: 'Test Project 2',
          agentId: 'gardener',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockProjectProvider.hasProjects).thenReturn(true);
      when(mockProjectProvider.projects).thenReturn(projects);
      when(mockProjectProvider.projectCount).thenReturn(2);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Project 1'), findsOneWidget);
      expect(find.text('Test Project 2'), findsOneWidget);
      expect(find.text('projects: 2'), findsOneWidget);
    });

    testWidgets('should show new project button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('newProject'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      when(mockProjectProvider.isLoading).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display project with favorite indicator', (WidgetTester tester) async {
      // Arrange
      final project = Project(
        id: '1',
        title: 'Favorite Project',
        agentId: 'gardener',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: true,
      );

      when(mockProjectProvider.hasProjects).thenReturn(true);
      when(mockProjectProvider.projects).thenReturn([project]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Favorite Project'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should show close button in header', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display projects header with icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('projects'), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });
  });
}
