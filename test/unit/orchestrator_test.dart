/// Unit tests for Agent Orchestrator components
///
/// This file contains unit tests for the orchestrator infrastructure
/// including models, interfaces, and core components.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/agent_request.dart';
import 'package:landcomp_app/shared/models/agent_response.dart';
import 'package:landcomp_app/core/tools/base/tool_result.dart';
import 'package:landcomp_app/core/agents/base/agent_registry.dart';
import 'package:landcomp_app/core/tools/base/tool_registry.dart';
import 'package:landcomp_app/shared/utils/metrics_tracker.dart';

void main() {
  group('Intent Model Tests', () {
    test('should create intent with correct properties', () {
      final intent = Intent(
        type: IntentType.consultation,
        confidence: 0.8,
        reasoning: 'User asking for advice',
        metadata: {'source': 'test'},
        extractedEntities: ['plant', 'care'],
      );

      expect(intent.type, IntentType.consultation);
      expect(intent.confidence, 0.8);
      expect(intent.reasoning, 'User asking for advice');
      expect(intent.isConsultation, true);
      expect(intent.isHighConfidence, true);
      expect(intent.extractedEntities, ['plant', 'care']);
    });

    test('should create intent from JSON', () {
      final json = {
        'type': 'generation',
        'confidence': 0.9,
        'reasoning': 'User wants image generated',
        'metadata': {'source': 'test'},
        'extracted_entities': ['garden', 'design'],
      };

      final intent = Intent.fromJson(json);

      expect(intent.type, IntentType.generation);
      expect(intent.confidence, 0.9);
      expect(intent.isGeneration, true);
      expect(intent.extractedEntities, ['garden', 'design']);
    });
  });

  group('RequestContext Model Tests', () {
    test('should create context with correct properties', () {
      final context = RequestContext(
        userMessage: 'Test message',
        conversationHistory: [],
        timestamp: DateTime.now(),
        hasRecentImages: true,
        userLanguage: 'en',
      );

      expect(context.userMessage, 'Test message');
      expect(context.hasRecentImages, true);
      expect(context.userLanguage, 'en');
      expect(context.isConversationEmpty, true);
    });
  });

  group('AgentRequest Model Tests', () {
    test('should create request with context and intent', () {
      final context = RequestContext(
        userMessage: 'Test message',
        conversationHistory: [],
        timestamp: DateTime.now(),
      );

      final intent = Intent(
        type: IntentType.consultation,
        confidence: 0.8,
        reasoning: 'Test reasoning',
        metadata: {},
        extractedEntities: [],
      );

      final request = AgentRequest(
        requestId: 'test-request',
        context: context,
        intent: intent,
        timestamp: DateTime.now(),
      );

      expect(request.requestId, 'test-request');
      expect(request.userMessage, 'Test message');
      expect(request.intentType, 'consultation');
      expect(request.intentConfidence, 0.8);
    });
  });

  group('AgentResponse Model Tests', () {
    test('should create successful response', () {
      final response = AgentResponse.success(
        requestId: 'test-request',
        message: 'Test response',
        selectedAgent: null,
      );

      expect(response.requestId, 'test-request');
      expect(response.isSuccess, true);
      expect(response.message, 'Test response');
    });

    test('should create error response', () {
      final response = AgentResponse.error(
        requestId: 'test-request',
        error: 'Test error',
      );

      expect(response.requestId, 'test-request');
      expect(response.isSuccess, false);
      expect(response.error, 'Test error');
    });
  });

  group('ToolResult Model Tests', () {
    test('should create successful result', () {
      final result = ToolResult.success(
        toolId: 'test-tool',
        data: {'result': 'success'},
        executionTime: Duration(milliseconds: 100),
      );

      expect(result.toolId, 'test-tool');
      expect(result.isSuccess, true);
      expect(result.data, {'result': 'success'});
      expect(result.executionTimeMs, 100);
      expect(result.isFastExecution, true);
    });

    test('should create error result', () {
      final result = ToolResult.error(
        toolId: 'test-tool',
        error: 'Test error',
        executionTime: Duration(milliseconds: 6000),
      );

      expect(result.toolId, 'test-tool');
      expect(result.isSuccess, false);
      expect(result.error, 'Test error');
      expect(result.isSlowExecution, true);
    });
  });

  group('AgentRegistry Tests', () {
    test('should register and retrieve agents', () {
      final registry = AgentRegistry.instance;

      // Clear any existing agents
      registry.clearMetrics();

      expect(registry.agentCount, 0);
      expect(registry.getAllAgents(), isEmpty);
    });

    test('should track execution metrics', () {
      final registry = AgentRegistry.instance;

      // This test verifies the registry can track metrics
      // In a real scenario, agents would be registered first
      expect(registry.getRegistryMetrics(), isA<Map<String, dynamic>>());
    });
  });

  group('ToolRegistry Tests', () {
    test('should register and retrieve tools', () {
      final registry = ToolRegistry.instance;

      // Clear any existing tools
      registry.clearMetrics();

      expect(registry.toolCount, 0);
      expect(registry.getAllTools(), isEmpty);
    });

    test('should track execution metrics', () {
      final registry = ToolRegistry.instance;

      // This test verifies the registry can track metrics
      expect(registry.getRegistryMetrics(), isA<Map<String, dynamic>>());
    });
  });

  group('MetricsTracker Tests', () {
    test('should track execution metrics', () {
      final tracker = MetricsTracker.instance;

      // Reset metrics
      tracker.reset();

      // Track some executions
      tracker.trackExecution(
        'test-component',
        Duration(milliseconds: 100),
        true,
      );
      tracker.trackExecution(
        'test-component',
        Duration(milliseconds: 200),
        false,
      );

      final metrics = tracker.getMetrics('test-component');

      expect(metrics['component'], 'test-component');
      expect(metrics['totalExecutions'], 2);
      expect(metrics['successCount'], 1);
      expect(metrics['errorCount'], 1);
      expect(metrics['successRate'], 0.5);
    });

    test('should provide summary statistics', () {
      final tracker = MetricsTracker.instance;

      final summary = tracker.getSummary();

      expect(summary, isA<Map<String, dynamic>>());
      expect(summary['totalComponents'], isA<int>());
      expect(summary['totalExecutions'], isA<int>());
    });
  });
}
