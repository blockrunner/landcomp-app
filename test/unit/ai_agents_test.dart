/// Unit tests for AI Agents
/// 
/// Tests specialized prompts, localization, and agent selection logic
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';

void main() {
  group('AIAgent Localization', () {
    test('should return English name for English language', () {
      // Arrange
      const agent = AIAgent(
        id: 'gardener',
        name: 'Gardener',
        description: 'Expert in plants and gardening',
        systemPrompt: 'You are a gardening expert',
        icon: Icons.local_florist,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['gardening'],
      );

      // Act
      final localizedName = agent.getLocalizedName('en');

      // Assert
      expect(localizedName, equals('Gardener'));
    });

    test('should return Russian name for Russian language', () {
      // Arrange
      const agent = AIAgent(
        id: 'gardener',
        name: 'Gardener',
        description: 'Expert in plants and gardening',
        systemPrompt: 'You are a gardening expert',
        icon: Icons.local_florist,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['gardening'],
      );

      // Act
      final localizedName = agent.getLocalizedName('ru');

      // Assert
      expect(localizedName, equals('Садовод'));
    });

    test('should return English name for unknown language', () {
      // Arrange
      const agent = AIAgent(
        id: 'gardener',
        name: 'Gardener',
        description: 'Expert in plants and gardening',
        systemPrompt: 'You are a gardening expert',
        icon: Icons.local_florist,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['gardening'],
      );

      // Act
      final localizedName = agent.getLocalizedName('fr');

      // Assert
      expect(localizedName, equals('Gardener'));
    });

    test('should return English description for English language', () {
      // Arrange
      const agent = AIAgent(
        id: 'landscape_designer',
        name: 'Landscape Designer',
        description: 'Expert in landscape design and planning',
        systemPrompt: 'You are a professional landscape designer',
        icon: Icons.home,
        primaryColor: Colors.blue,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['landscape design'],
      );

      // Act
      final localizedDescription = agent.getLocalizedDescription('en');

      // Assert
      expect(localizedDescription, equals('Expert in landscape design and planning'));
    });

    test('should return Russian description for Russian language', () {
      // Arrange
      const agent = AIAgent(
        id: 'landscape_designer',
        name: 'Landscape Designer',
        description: 'Expert in landscape design and planning',
        systemPrompt: 'You are a professional landscape designer',
        icon: Icons.home,
        primaryColor: Colors.blue,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['landscape design'],
      );

      // Act
      final localizedDescription = agent.getLocalizedDescription('ru');

      // Assert
      expect(localizedDescription, equals('Специалист по планированию участков и зонированию'));
    });

    test('should return English system prompt for English language', () {
      // Arrange
      const agent = AIAgent(
        id: 'builder',
        name: 'Builder',
        description: 'Expert in construction and materials',
        systemPrompt: 'You are a construction expert',
        icon: Icons.build,
        primaryColor: Colors.orange,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['construction'],
      );

      // Act
      final localizedPrompt = agent.getLocalizedSystemPrompt('en');

      // Assert
      expect(localizedPrompt, equals('You are a construction expert'));
    });

    test('should return Russian system prompt for Russian language', () {
      // Arrange
      const agent = AIAgent(
        id: 'builder',
        name: 'Builder',
        description: 'Expert in construction and materials',
        systemPrompt: 'You are a construction expert',
        icon: Icons.build,
        primaryColor: Colors.orange,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['construction'],
      );

      // Act
      final localizedPrompt = agent.getLocalizedSystemPrompt('ru');

      // Assert
      expect(localizedPrompt, contains('Ты - опытный строитель'));
      expect(localizedPrompt, contains('Строительство домов'));
      expect(localizedPrompt, contains('российских стандартов'));
    });

    test('should return English quick start suggestions for English language', () {
      // Arrange
      const agent = AIAgent(
        id: 'ecologist',
        name: 'Ecologist',
        description: 'Expert in environmental solutions',
        systemPrompt: 'You are an environmental expert',
        icon: Icons.eco,
        primaryColor: Colors.green,
        quickStartSuggestions: ['How to create eco-friendly garden?'],
        expertiseAreas: ['ecology'],
      );

      // Act
      final localizedSuggestions = agent.getLocalizedQuickStartSuggestions('en');

      // Assert
      expect(localizedSuggestions, equals(['How to create eco-friendly garden?']));
    });

    test('should return Russian quick start suggestions for Russian language', () {
      // Arrange
      const agent = AIAgent(
        id: 'ecologist',
        name: 'Ecologist',
        description: 'Expert in environmental solutions',
        systemPrompt: 'You are an environmental expert',
        icon: Icons.eco,
        primaryColor: Colors.green,
        quickStartSuggestions: ['How to create eco-friendly garden?'],
        expertiseAreas: ['ecology'],
      );

      // Act
      final localizedSuggestions = agent.getLocalizedQuickStartSuggestions('ru');

      // Assert
      expect(localizedSuggestions, contains('🌱 Как создать экологичный сад?'));
      expect(localizedSuggestions, contains('♻️ Как перерабатывать органические отходы?'));
      expect(localizedSuggestions, contains('💧 Как использовать дождевую воду?'));
      expect(localizedSuggestions, contains('🌿 Какие растения улучшают экологию?'));
    });
  });

  group('AIAgent Properties', () {
    test('should have correct properties for gardener agent', () {
      // Arrange & Act
      const agent = AIAgent(
        id: 'gardener',
        name: 'Gardener',
        description: 'Expert in plants and gardening',
        systemPrompt: 'You are a gardening expert',
        icon: Icons.local_florist,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['gardening'],
      );

      // Assert
      expect(agent.id, equals('gardener'));
      expect(agent.name, equals('Gardener'));
      expect(agent.description, equals('Expert in plants and gardening'));
      expect(agent.systemPrompt, equals('You are a gardening expert'));
      expect(agent.icon, equals(Icons.local_florist));
      expect(agent.primaryColor, equals(Colors.green));
      expect(agent.quickStartSuggestions, equals(['Test suggestion']));
      expect(agent.expertiseAreas, equals(['gardening']));
      expect(agent.isActive, equals(true));
    });

    test('should have correct properties for landscape designer agent', () {
      // Arrange & Act
      const agent = AIAgent(
        id: 'landscape_designer',
        name: 'Landscape Designer',
        description: 'Expert in landscape design and planning',
        systemPrompt: 'You are a professional landscape designer',
        icon: Icons.home,
        primaryColor: Colors.blue,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['landscape design'],
      );

      // Assert
      expect(agent.id, equals('landscape_designer'));
      expect(agent.name, equals('Landscape Designer'));
      expect(agent.description, equals('Expert in landscape design and planning'));
      expect(agent.systemPrompt, equals('You are a professional landscape designer'));
      expect(agent.icon, equals(Icons.home));
      expect(agent.primaryColor, equals(Colors.blue));
      expect(agent.quickStartSuggestions, equals(['Test suggestion']));
      expect(agent.expertiseAreas, equals(['landscape design']));
      expect(agent.isActive, equals(true));
    });

    test('should have correct properties for builder agent', () {
      // Arrange & Act
      const agent = AIAgent(
        id: 'builder',
        name: 'Builder',
        description: 'Expert in construction and materials',
        systemPrompt: 'You are a construction expert',
        icon: Icons.build,
        primaryColor: Colors.orange,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['construction'],
      );

      // Assert
      expect(agent.id, equals('builder'));
      expect(agent.name, equals('Builder'));
      expect(agent.description, equals('Expert in construction and materials'));
      expect(agent.systemPrompt, equals('You are a construction expert'));
      expect(agent.icon, equals(Icons.build));
      expect(agent.primaryColor, equals(Colors.orange));
      expect(agent.quickStartSuggestions, equals(['Test suggestion']));
      expect(agent.expertiseAreas, equals(['construction']));
      expect(agent.isActive, equals(true));
    });

    test('should have correct properties for ecologist agent', () {
      // Arrange & Act
      const agent = AIAgent(
        id: 'ecologist',
        name: 'Ecologist',
        description: 'Expert in environmental solutions',
        systemPrompt: 'You are an environmental expert',
        icon: Icons.eco,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['ecology'],
      );

      // Assert
      expect(agent.id, equals('ecologist'));
      expect(agent.name, equals('Ecologist'));
      expect(agent.description, equals('Expert in environmental solutions'));
      expect(agent.systemPrompt, equals('You are an environmental expert'));
      expect(agent.icon, equals(Icons.eco));
      expect(agent.primaryColor, equals(Colors.green));
      expect(agent.quickStartSuggestions, equals(['Test suggestion']));
      expect(agent.expertiseAreas, equals(['ecology']));
      expect(agent.isActive, equals(true));
    });

    test('should support inactive agent', () {
      // Arrange & Act
      const agent = AIAgent(
        id: 'inactive_agent',
        name: 'Inactive Agent',
        description: 'This agent is inactive',
        systemPrompt: 'You are inactive',
        icon: Icons.block,
        primaryColor: Colors.grey,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['inactive'],
        isActive: false,
      );

      // Assert
      expect(agent.id, equals('inactive_agent'));
      expect(agent.name, equals('Inactive Agent'));
      expect(agent.isActive, equals(false));
    });
  });

  group('AIAgent Equality', () {
    test('should be equal when IDs match', () {
      // Arrange
      const agent1 = AIAgent(
        id: 'test_agent',
        name: 'Test Agent',
        description: 'Test description',
        systemPrompt: 'Test prompt',
        icon: Icons.help,
        primaryColor: Colors.red,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['test'],
      );

      const agent2 = AIAgent(
        id: 'test_agent',
        name: 'Different Name',
        description: 'Different description',
        systemPrompt: 'Different prompt',
        icon: Icons.info,
        primaryColor: Colors.blue,
        quickStartSuggestions: ['Different suggestion'],
        expertiseAreas: ['different'],
      );

      // Assert
      expect(agent1, equals(agent2));
      expect(agent1.hashCode, equals(agent2.hashCode));
    });

    test('should not be equal when IDs differ', () {
      // Arrange
      const agent1 = AIAgent(
        id: 'agent1',
        name: 'Agent 1',
        description: 'Description 1',
        systemPrompt: 'Prompt 1',
        icon: Icons.help,
        primaryColor: Colors.red,
        quickStartSuggestions: ['Suggestion 1'],
        expertiseAreas: ['area1'],
      );

      const agent2 = AIAgent(
        id: 'agent2',
        name: 'Agent 2',
        description: 'Description 2',
        systemPrompt: 'Prompt 2',
        icon: Icons.help,
        primaryColor: Colors.red,
        quickStartSuggestions: ['Suggestion 2'],
        expertiseAreas: ['area2'],
      );

      // Assert
      expect(agent1, isNot(equals(agent2)));
      expect(agent1.hashCode, isNot(equals(agent2.hashCode)));
    });
  });

  group('AIAgent String Representation', () {
    test('should have proper toString', () {
      // Arrange
      const agent = AIAgent(
        id: 'test_agent',
        name: 'Test Agent',
        description: 'Test description',
        systemPrompt: 'Test prompt',
        icon: Icons.help,
        primaryColor: Colors.red,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['test'],
      );

      // Act
      final stringRepresentation = agent.toString();

      // Assert
      expect(stringRepresentation, equals('AIAgent(id: test_agent, name: Test Agent)'));
    });
  });

  group('AIAgent Russian Localization', () {
    test('should return correct Russian names for all agents', () {
      // Arrange
      const gardener = AIAgent(
        id: 'gardener',
        name: 'Gardener',
        description: 'Expert in plants and gardening',
        systemPrompt: 'You are a gardening expert',
        icon: Icons.local_florist,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['gardening'],
      );

      const landscapeDesigner = AIAgent(
        id: 'landscape_designer',
        name: 'Landscape Designer',
        description: 'Expert in landscape design and planning',
        systemPrompt: 'You are a professional landscape designer',
        icon: Icons.home,
        primaryColor: Colors.blue,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['landscape design'],
      );

      const builder = AIAgent(
        id: 'builder',
        name: 'Builder',
        description: 'Expert in construction and materials',
        systemPrompt: 'You are a construction expert',
        icon: Icons.build,
        primaryColor: Colors.orange,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['construction'],
      );

      const ecologist = AIAgent(
        id: 'ecologist',
        name: 'Ecologist',
        description: 'Expert in environmental solutions',
        systemPrompt: 'You are an environmental expert',
        icon: Icons.eco,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['ecology'],
      );

      // Act & Assert
      expect(gardener.getLocalizedName('ru'), equals('Садовод'));
      expect(landscapeDesigner.getLocalizedName('ru'), equals('Ландшафтный дизайнер'));
      expect(builder.getLocalizedName('ru'), equals('Строитель'));
      expect(ecologist.getLocalizedName('ru'), equals('Эколог'));
    });

    test('should return correct Russian descriptions for all agents', () {
      // Arrange
      const gardener = AIAgent(
        id: 'gardener',
        name: 'Gardener',
        description: 'Expert in plants and gardening',
        systemPrompt: 'You are a gardening expert',
        icon: Icons.local_florist,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['gardening'],
      );

      const landscapeDesigner = AIAgent(
        id: 'landscape_designer',
        name: 'Landscape Designer',
        description: 'Expert in landscape design and planning',
        systemPrompt: 'You are a professional landscape designer',
        icon: Icons.home,
        primaryColor: Colors.blue,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['landscape design'],
      );

      const builder = AIAgent(
        id: 'builder',
        name: 'Builder',
        description: 'Expert in construction and materials',
        systemPrompt: 'You are a construction expert',
        icon: Icons.build,
        primaryColor: Colors.orange,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['construction'],
      );

      const ecologist = AIAgent(
        id: 'ecologist',
        name: 'Ecologist',
        description: 'Expert in environmental solutions',
        systemPrompt: 'You are an environmental expert',
        icon: Icons.eco,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['ecology'],
      );

      // Act & Assert
      expect(gardener.getLocalizedDescription('ru'), equals('Эксперт по растениям, уходу и сезонным работам'));
      expect(landscapeDesigner.getLocalizedDescription('ru'), equals('Специалист по планированию участков и зонированию'));
      expect(builder.getLocalizedDescription('ru'), equals('Эксперт по строительству и материалам'));
      expect(ecologist.getLocalizedDescription('ru'), equals('Специалист по экологичным решениям'));
    });
  });
}
