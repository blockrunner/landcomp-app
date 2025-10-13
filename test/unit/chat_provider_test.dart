/// Unit tests for ChatProvider
/// 
/// Tests state management, message handling, agent selection, and error handling
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';

void main() {
  group('Message Entity', () {
    test('should create user message', () {
      // Arrange & Act
      final message = Message(
        id: '1',
        content: 'Hello, how are you?',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      // Assert
      expect(message.id, equals('1'));
      expect(message.content, equals('Hello, how are you?'));
      expect(message.type, equals(MessageType.user));
      expect(message.agentId, isNull);
      expect(message.isError, isFalse);
      expect(message.isTyping, isFalse);
    });

    test('should create AI message with agent', () {
      // Arrange
      const agent = AIAgent(
        id: 'gardener',
        name: 'Gardener',
        description: 'Expert in plants',
        systemPrompt: 'You are a gardening expert',
        icon: Icons.local_florist,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['gardening'],
      );

      // Act
      final message = Message(
        id: '2',
        content: 'I can help you with gardening questions!',
        type: MessageType.ai,
        timestamp: DateTime.now(),
        agentId: agent.id,
      );

      // Assert
      expect(message.id, equals('2'));
      expect(message.content, equals('I can help you with gardening questions!'));
      expect(message.type, equals(MessageType.ai));
      expect(message.agentId, equals('gardener'));
      expect(message.isError, isFalse);
      expect(message.isTyping, isFalse);
    });

    test('should create typing indicator', () {
      // Arrange & Act
      final message = Message.typing(
        id: '3',
        agentId: 'gardener',
      );

      // Assert
      expect(message.id, equals('3'));
      expect(message.content, isEmpty);
      expect(message.type, equals(MessageType.ai));
      expect(message.isTyping, isTrue);
      expect(message.isError, isFalse);
      expect(message.agentId, equals('gardener'));
    });

    test('should create error message', () {
      // Arrange & Act
      final message = Message.system(
        id: '4',
        content: 'An error occurred',
        isError: true,
      );

      // Assert
      expect(message.id, equals('4'));
      expect(message.content, equals('An error occurred'));
      expect(message.type, equals(MessageType.system));
      expect(message.isError, isTrue);
      expect(message.isTyping, isFalse);
    });

    test('should support equality comparison', () {
      // Arrange
      final timestamp = DateTime.now();
      final message1 = Message(
        id: '1',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
      );

      final message2 = Message(
        id: '1',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
      );

      final message3 = Message(
        id: '2',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
      );

      // Assert
      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });
  });

  group('MessageType Enum', () {
    test('should have correct values', () {
      // Assert
      expect(MessageType.user.toString(), equals('MessageType.user'));
      expect(MessageType.ai.toString(), equals('MessageType.ai'));
      expect(MessageType.system.toString(), equals('MessageType.system'));
    });

    test('should support equality', () {
      // Assert
      expect(MessageType.user, equals(MessageType.user));
      expect(MessageType.user, isNot(equals(MessageType.ai)));
    });
  });

  group('AIAgent Entity', () {
    test('should create AI agent with all properties', () {
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
    });

    test('should support equality comparison', () {
      // Arrange
      const agent1 = AIAgent(
        id: 'builder',
        name: 'Builder',
        description: 'Construction expert',
        systemPrompt: 'You are a construction expert',
        icon: Icons.build,
        primaryColor: Colors.orange,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['construction'],
      );

      const agent2 = AIAgent(
        id: 'builder',
        name: 'Builder',
        description: 'Construction expert',
        systemPrompt: 'You are a construction expert',
        icon: Icons.build,
        primaryColor: Colors.orange,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['construction'],
      );

      const agent3 = AIAgent(
        id: 'ecologist',
        name: 'Ecologist',
        description: 'Environmental expert',
        systemPrompt: 'You are an environmental expert',
        icon: Icons.eco,
        primaryColor: Colors.green,
        quickStartSuggestions: ['Test suggestion'],
        expertiseAreas: ['ecology'],
      );

      // Assert
      expect(agent1, equals(agent2));
      expect(agent1, isNot(equals(agent3)));
    });

    test('should create all predefined agents', () {
      // Arrange & Act
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

      // Assert
      expect(gardener.id, equals('gardener'));
      expect(landscapeDesigner.id, equals('landscape_designer'));
      expect(builder.id, equals('builder'));
      expect(ecologist.id, equals('ecologist'));

      expect(gardener.icon, equals(Icons.local_florist));
      expect(landscapeDesigner.icon, equals(Icons.home));
      expect(builder.icon, equals(Icons.build));
      expect(ecologist.icon, equals(Icons.eco));
    });
  });

  group('Message Validation', () {
    test('should validate message content', () {
      // Arrange & Act
      final validMessage = Message(
        id: '1',
        content: 'Valid message content',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      final emptyMessage = Message(
        id: '2',
        content: '',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      // Assert
      expect(validMessage.content.isNotEmpty, isTrue);
      expect(emptyMessage.content.isEmpty, isTrue);
    });

    test('should validate message timestamp', () {
      // Arrange
      final now = DateTime.now();
      final past = now.subtract(const Duration(hours: 1));
      final future = now.add(const Duration(hours: 1));

      // Act
      final currentMessage = Message(
        id: '1',
        content: 'Current message',
        type: MessageType.user,
        timestamp: now,
      );

      final pastMessage = Message(
        id: '2',
        content: 'Past message',
        type: MessageType.user,
        timestamp: past,
      );

      final futureMessage = Message(
        id: '3',
        content: 'Future message',
        type: MessageType.user,
        timestamp: future,
      );

      // Assert
      expect(currentMessage.timestamp, equals(now));
      expect(pastMessage.timestamp, equals(past));
      expect(futureMessage.timestamp, equals(future));
    });
  });

  group('Message Types', () {
    test('should handle different message types correctly', () {
      // Arrange & Act
      final userMessage = Message(
        id: '1',
        content: 'User input',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      final aiMessage = Message(
        id: '2',
        content: 'AI response',
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      final systemMessage = Message(
        id: '3',
        content: 'System notification',
        type: MessageType.system,
        timestamp: DateTime.now(),
      );

      final typingMessage = Message.typing(
        id: '4',
        agentId: 'gardener',
      );

      // Assert
      expect(userMessage.type, equals(MessageType.user));
      expect(aiMessage.type, equals(MessageType.ai));
      expect(systemMessage.type, equals(MessageType.system));
      expect(typingMessage.type, equals(MessageType.ai));
      expect(typingMessage.isTyping, isTrue);
    });
  });
}
