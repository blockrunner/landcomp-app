/// Widget tests for AgentSelector component
/// 
/// Tests the visual rendering and behavior of agent selection widgets
/// including grid layout, list layout, and compact selector.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';
import 'package:landcomp_app/features/chat/presentation/widgets/agent_selector.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';

void main() {
  group('AgentSelector Widget Tests', () {
    late AIAgent gardenerAgent;
    late AIAgent landscapeAgent;
    late AIAgent builderAgent;
    late AIAgent ecologistAgent;

    setUp(() {
      gardenerAgent = AIAgentsConfig.gardenerAgent;
      landscapeAgent = AIAgentsConfig.landscapeDesignerAgent;
      builderAgent = AIAgentsConfig.builderAgent;
      ecologistAgent = AIAgentsConfig.ecologistAgent;
    });

    Widget createTestWidget({
      required AIAgent currentAgent,
      required ValueChanged<AIAgent> onAgentSelected,
      LanguageProvider? languageProvider,
      bool showAsGrid = true,
    }) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          body: AgentSelector(
            currentAgent: currentAgent,
            onAgentSelected: onAgentSelected,
            languageProvider: languageProvider,
            showAsGrid: showAsGrid,
          ),
        ),
      );
    }

    testWidgets('should display all agents in grid layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // Check if all agents are displayed
      expect(find.text('Gardener'), findsOneWidget);
      expect(find.text('Landscape Designer'), findsOneWidget);
      expect(find.text('Builder'), findsOneWidget);
      expect(find.text('Ecologist'), findsOneWidget);

      // Check if agent icons are displayed
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
      expect(find.byIcon(Icons.landscape), findsOneWidget);
      expect(find.byIcon(Icons.build), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsOneWidget);
    });

    testWidgets('should display all agents in list layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
        showAsGrid: false,
      ));

      // Check if all agents are displayed in list format
      expect(find.text('Gardener'), findsOneWidget);
      expect(find.text('Landscape Designer'), findsOneWidget);
      expect(find.text('Builder'), findsOneWidget);
      expect(find.text('Ecologist'), findsOneWidget);

      // Check if GridView is not present in list layout
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should highlight selected agent in grid layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        currentAgent: landscapeAgent,
        onAgentSelected: (agent) {},
      ));

      // Find the selected agent card
      final selectedCard = find.ancestor(
        of: find.text('Landscape Designer'),
        matching: find.byType(Card),
      );

      expect(selectedCard, findsOneWidget);

      // Check if the card has elevated appearance
      final card = tester.widget<Card>(selectedCard);
      expect(card.elevation, greaterThan(1));
    });

    testWidgets('should highlight selected agent in list layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        currentAgent: builderAgent,
        onAgentSelected: (agent) {},
        showAsGrid: false,
      ));

      // Find the selected agent card
      final selectedCard = find.ancestor(
        of: find.text('Builder'),
        matching: find.byType(Card),
      );

      expect(selectedCard, findsOneWidget);

      // Check if the card has elevated appearance
      final card = tester.widget<Card>(selectedCard);
      expect(card.elevation, greaterThan(1));
    });

    testWidgets('should call onAgentSelected when agent is tapped in grid', (WidgetTester tester) async {
      AIAgent? selectedAgent;
      
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) => selectedAgent = agent,
      ));

      // Tap on landscape designer agent
      await tester.tap(find.text('Landscape Designer'));
      await tester.pump();

      expect(selectedAgent, equals(landscapeAgent));
    });

    testWidgets('should call onAgentSelected when agent is tapped in list', (WidgetTester tester) async {
      AIAgent? selectedAgent;
      
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) => selectedAgent = agent,
        showAsGrid: false,
      ));

      // Tap on ecologist agent
      await tester.tap(find.text('Ecologist'));
      await tester.pump();

      expect(selectedAgent, equals(ecologistAgent));
    });

    testWidgets('should display agent descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // Check if descriptions are displayed (using actual descriptions from config)
      expect(find.textContaining('Expert in plants'), findsOneWidget);
      expect(find.textContaining('Specialist in site planning'), findsOneWidget);
      expect(find.textContaining('Expert in construction'), findsOneWidget);
      expect(find.textContaining('Specialist in eco-friendly'), findsOneWidget);
    });

    testWidgets('should display check icon for selected agent in list layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        currentAgent: ecologistAgent,
        onAgentSelected: (agent) {},
        showAsGrid: false,
      ));

      // Check if check icon is displayed for selected agent
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should handle agent selection with different agents', (WidgetTester tester) async {
      AIAgent? selectedAgent;
      
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) => selectedAgent = agent,
      ));

      // Test selecting different agents
      await tester.tap(find.text('Builder'));
      await tester.pump();
      expect(selectedAgent, equals(builderAgent));

      await tester.tap(find.text('Ecologist'));
      await tester.pump();
      expect(selectedAgent, equals(ecologistAgent));
    });

    testWidgets('should display proper agent colors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // All agent cards should be displayed with their respective colors
      expect(find.byType(Card), findsNWidgets(4));
    });

    testWidgets('should handle rapid agent selection', (WidgetTester tester) async {
      var selectionCount = 0;
      
      await tester.pumpWidget(createTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) => selectionCount++,
      ));

      // Rapidly tap different agents
      await tester.tap(find.text('Landscape Designer'));
      await tester.tap(find.text('Builder'));
      await tester.tap(find.text('Ecologist'));
      await tester.pump();

      expect(selectionCount, equals(3));
    });
  });

  group('CompactAgentSelector Widget Tests', () {
    late AIAgent gardenerAgent;

    setUp(() {
      gardenerAgent = AIAgentsConfig.gardenerAgent;
    });

    Widget createCompactTestWidget({
      required AIAgent currentAgent,
      required ValueChanged<AIAgent> onAgentSelected,
      LanguageProvider? languageProvider,
    }) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: CompactAgentSelector(
              currentAgent: currentAgent,
              onAgentSelected: onAgentSelected,
              languageProvider: languageProvider,
            ),
          ),
        ),
      );
    }

    testWidgets('should display current agent in compact selector', (WidgetTester tester) async {
      await tester.pumpWidget(createCompactTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // Check if current agent name is displayed
      expect(find.text('Gardener'), findsOneWidget);

      // Check if current agent icon is displayed
      expect(find.byIcon(Icons.local_florist), findsOneWidget);

      // Check if dropdown arrow is displayed
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('should open popup menu when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createCompactTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // Tap on the compact selector
      await tester.tap(find.byType(PopupMenuButton<AIAgent>));
      await tester.pumpAndSettle();

      // Check if popup menu is displayed
      expect(find.byType(PopupMenuItem<AIAgent>), findsNWidgets(4));
    });

    testWidgets('should display all agents in popup menu', (WidgetTester tester) async {
      await tester.pumpWidget(createCompactTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<AIAgent>));
      await tester.pumpAndSettle();

      // Check if all agents are in the menu
      expect(find.text('Gardener'), findsWidgets);
      expect(find.text('Landscape Designer'), findsOneWidget);
      expect(find.text('Builder'), findsOneWidget);
      expect(find.text('Ecologist'), findsOneWidget);
    });

    testWidgets('should call onAgentSelected when agent is selected from popup', (WidgetTester tester) async {
      AIAgent? selectedAgent;
      
      await tester.pumpWidget(createCompactTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) => selectedAgent = agent,
      ));

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<AIAgent>));
      await tester.pumpAndSettle();

      // Select landscape designer
      await tester.tap(find.text('Landscape Designer'));
      await tester.pumpAndSettle();

      expect(selectedAgent, equals(AIAgentsConfig.landscapeDesignerAgent));
    });

    testWidgets('should show check icon for selected agent in popup', (WidgetTester tester) async {
      await tester.pumpWidget(createCompactTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<AIAgent>));
      await tester.pumpAndSettle();

      // Check if check icon is displayed for current agent
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should display agent icons in popup menu', (WidgetTester tester) async {
      await tester.pumpWidget(createCompactTestWidget(
        currentAgent: gardenerAgent,
        onAgentSelected: (agent) {},
      ));

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<AIAgent>));
      await tester.pumpAndSettle();

      // Check if agent icons are displayed in popup
      expect(find.byIcon(Icons.local_florist), findsWidgets);
      expect(find.byIcon(Icons.landscape), findsOneWidget);
      expect(find.byIcon(Icons.build), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsOneWidget);
    });
  });
}
