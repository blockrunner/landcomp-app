/// Simplified unit tests for AI Service
///
/// Tests core functionality without complex mocking
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';

void main() {
  group('AIService', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService.instance;
    });

    group('Service Status', () {
      test('should return service status map', () {
        // Act
        final status = aiService.getStatus();

        // Assert
        expect(status, isA<Map<String, dynamic>>());
        expect(status.containsKey('openai_configured'), isTrue);
        expect(status.containsKey('google_configured'), isTrue);
        expect(status.containsKey('proxy_configured'), isTrue);
        expect(status.containsKey('current_proxy'), isTrue);
        expect(status.containsKey('current_google_key'), isTrue);
      });

      test('should have correct status keys', () {
        // Act
        final status = aiService.getStatus();

        // Assert
        expect(
          status.keys,
          containsAll([
            'openai_configured',
            'google_configured',
            'proxy_configured',
            'current_proxy',
            'current_google_key',
          ]),
        );
      });
    });

    group('SmartAIResponse', () {
      test('should create successful response', () {
        // Arrange
        const message = 'Test response';
        const confidence = 0.9;
        const agent = AIAgent(
          id: 'test',
          name: 'Test Agent',
          description: 'Test description',
          systemPrompt: 'Test prompt',
          icon: '🧪',
          color: 0xFF000000,
        );

        // Act
        final response = SmartAIResponse.success(
          message: message,
          agent: agent,
          confidence: confidence,
        );

        // Assert
        expect(response.isSuccess, isTrue);
        expect(response.isOutOfScope, isFalse);
        expect(response.isError, isFalse);
        expect(response.message, equals(message));
        expect(response.agent, equals(agent));
        expect(response.confidence, equals(confidence));
      });

      test('should create out of scope response', () {
        // Arrange
        const message = 'Out of scope message';

        // Act
        final response = SmartAIResponse.outOfScope(message: message);

        // Assert
        expect(response.isSuccess, isFalse);
        expect(response.isOutOfScope, isTrue);
        expect(response.isError, isFalse);
        expect(response.message, equals(message));
        expect(response.agent, isNull);
        expect(response.confidence, isNull);
      });

      test('should create error response', () {
        // Arrange
        const message = 'Error message';

        // Act
        final response = SmartAIResponse.error(message: message);

        // Assert
        expect(response.isSuccess, isFalse);
        expect(response.isOutOfScope, isFalse);
        expect(response.isError, isTrue);
        expect(response.message, equals(message));
        expect(response.agent, isNull);
        expect(response.confidence, isNull);
      });
    });

    group('AIAgent Entity', () {
      test('should create AI agent with all properties', () {
        // Arrange & Act
        const agent = AIAgent(
          id: 'gardener',
          name: 'Gardener',
          description: 'Expert in plants and gardening',
          systemPrompt: 'You are a gardening expert',
          icon: '🌱',
          color: 0xFF4CAF50,
        );

        // Assert
        expect(agent.id, equals('gardener'));
        expect(agent.name, equals('Gardener'));
        expect(agent.description, equals('Expert in plants and gardening'));
        expect(agent.systemPrompt, equals('You are a gardening expert'));
        expect(agent.icon, equals('🌱'));
        expect(agent.color, equals(0xFF4CAF50));
      });

      test('should support equality comparison', () {
        // Arrange
        const agent1 = AIAgent(
          id: 'test',
          name: 'Test',
          description: 'Test',
          systemPrompt: 'Test',
          icon: '🧪',
          color: 0xFF000000,
        );

        const agent2 = AIAgent(
          id: 'test',
          name: 'Test',
          description: 'Test',
          systemPrompt: 'Test',
          icon: '🧪',
          color: 0xFF000000,
        );

        const agent3 = AIAgent(
          id: 'different',
          name: 'Test',
          description: 'Test',
          systemPrompt: 'Test',
          icon: '🧪',
          color: 0xFF000000,
        );

        // Assert
        expect(agent1, equals(agent2));
        expect(agent1, isNot(equals(agent3)));
      });
    });

    group('Error Handling', () {
      test('should handle OpenAI not configured error', () async {
        // Act & Assert
        expect(
          () => aiService.sendToOpenAI(message: 'test', systemPrompt: 'test'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle Google Gemini not configured error', () async {
        // Act & Assert
        expect(
          () => aiService.sendToGemini(message: 'test', systemPrompt: 'test'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle no providers configured error', () async {
        // Act & Assert
        expect(
          () => aiService.sendMessage(message: 'test', systemPrompt: 'test'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Initialization', () {
      test('should initialize without throwing', () async {
        // Act & Assert
        expect(() => aiService.initialize(), returnsNormally);
      });
    });
  });
}
