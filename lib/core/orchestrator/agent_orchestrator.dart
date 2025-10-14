/// Agent Orchestrator - Central component for managing agents and requests
///
/// This orchestrator coordinates intent classification, context management,
/// agent selection, and request execution in the system.
library;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:landcomp_app/core/agents/base/agent.dart';
import 'package:landcomp_app/core/agents/base/agent_adapter.dart';
import 'package:landcomp_app/core/agents/base/agent_registry.dart';
import 'package:landcomp_app/core/orchestrator/context_manager.dart';
import 'package:landcomp_app/core/orchestrator/intent_classifier.dart';
import 'package:landcomp_app/core/tools/base/tool_registry.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/shared/models/agent_request.dart';
import 'package:landcomp_app/shared/models/agent_response.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/shared/utils/metrics_tracker.dart';

/// Central orchestrator for agent management and request processing
class AgentOrchestrator {
  AgentOrchestrator._();

  static final AgentOrchestrator _instance = AgentOrchestrator._();

  /// Singleton instance of the AgentOrchestrator
  static AgentOrchestrator get instance => _instance;

  final IntentClassifier _intentClassifier = IntentClassifier.instance;
  final ContextManager _contextManager = ContextManager.instance;
  final AgentRegistry _agentRegistry = AgentRegistry.instance;
  final ToolRegistry _toolRegistry = ToolRegistry.instance;
  final MetricsTracker _metricsTracker = MetricsTracker.instance;

  final _uuid = const Uuid();
  bool _isInitialized = false;

  /// Initialize the orchestrator
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🚀 Initializing Agent Orchestrator...');

    try {
      // Initialize registries
      await _initializeAgentRegistry();
      await _initializeToolRegistry();

      _isInitialized = true;
      debugPrint('✅ Agent Orchestrator initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Agent Orchestrator: $e');
      rethrow;
    }
  }

  /// Process a user request through the orchestrator
  Future<AgentResponse> processRequest({
    required String userMessage,
    required List<Message> conversationHistory,
    List<Attachment>? attachments,
    String? currentAgentId,
  }) async {
    final requestId = _uuid.v4();
    final startTime = DateTime.now();

    debugPrint('🎯 Processing request: $requestId');
    final messagePreview = userMessage.length > 50
        ? '${userMessage.substring(0, 50)}...'
        : userMessage;
    debugPrint('   Message: $messagePreview');
    debugPrint('   History: ${conversationHistory.length} messages');
    debugPrint('   Attachments: ${attachments?.length ?? 0}');
    debugPrint('🚀 AgentOrchestrator.processRequest called!');

    try {
      // 1. Build context
      final context = await _contextManager.buildContext(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        attachments: attachments,
        currentAgentId: currentAgentId,
      );

      // 2. Classify intent
      final intent = await _intentClassifier.classifyIntent(
        userMessage,
        context,
      );

      debugPrint(
        '   Intent: ${intent.type.name} (confidence: ${intent.confidence})',
      );
      if (intent.subtype != null) {
        debugPrint('   Subtype: ${intent.subtype!.name}');
      }

      // 2.5. Select relevant images based on intent
      final relevantImages = await _contextManager.getRelevantImages(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        intent: intent,
        currentAttachments: attachments,
      );

      debugPrint(
        '🖼️ Selected ${relevantImages.length} relevant images for request',
      );

      // Update context with selected images
      final updatedContext = context.copyWith(
        attachments: relevantImages,
        metadata: {
          ...context.metadata,
          'original_attachments_count': attachments?.length ?? 0,
          'selected_images_count': relevantImages.length,
          'image_intent': intent.imageIntent?.name,
        },
      );

      // 3. Create request with updated context
      final request = AgentRequest(
        requestId: requestId,
        context: updatedContext,
        intent: intent,
        timestamp: DateTime.now(),
      );

      // 4. Select agent
      debugPrint('🎯 Starting agent selection...');
      final agent = await _selectAgent(request);
      debugPrint('   Selected agent: ${agent.name}');

      // 5. Execute request
      final response = await agent.execute(request);

      // 6. Track metrics
      final executionTime = DateTime.now().difference(startTime);
      _metricsTracker.trackExecution(
        'orchestrator',
        executionTime,
        response.isSuccess,
      );
      _agentRegistry.trackExecution(
        agent.id,
        executionTime,
        response.isSuccess,
      );

      debugPrint(
        '✅ Request processed successfully in ${executionTime.inMilliseconds}ms',
      );
      return response;
    } catch (e) {
      final executionTime = DateTime.now().difference(startTime);
      _metricsTracker.trackExecution('orchestrator', executionTime, false);

      debugPrint('❌ Request processing failed: $e');
      return AgentResponse.error(
        requestId: requestId,
        error: 'Request processing failed: $e',
        metadata: {
          'execution_time_ms': executionTime.inMilliseconds,
          'error_type': e.runtimeType.toString(),
        },
      );
    }
  }

  /// Select the best agent for the request using scoring system
  Future<Agent> _selectAgent(AgentRequest request) async {
    debugPrint('🤖 Selecting agent for intent: ${request.intent.type.name}');

    // Get all agents that can handle this intent and context
    final agentScores = <Agent, double>{};

    for (final agent in _getAllAgents()) {
      try {
        final canHandle = await agent.canHandle(
          request.intent,
          request.context,
        );
        if (canHandle) {
          final score = await _calculateAgentScore(agent, request);
          agentScores[agent] = score;
          debugPrint('   ${agent.name}: score ${score.toStringAsFixed(2)}');

          // Debug scoring breakdown
          final intentScore = _getIntentScore(agent, request.intent);
          final contextScore = _getContextScore(agent, request.context);
          final keywordScore = _getKeywordScore(agent, request.userMessage);
          final performanceScore = _getPerformanceScore(agent);
          debugPrint(
            '     - Intent: ${intentScore.toStringAsFixed(2)}, '
            'Context: ${contextScore.toStringAsFixed(2)}, '
            'Keywords: ${keywordScore.toStringAsFixed(2)}, '
            'Performance: ${performanceScore.toStringAsFixed(2)}',
          );
        }
      } catch (e) {
        debugPrint('⚠️ Agent ${agent.id} failed capability check: $e');
      }
    }

    if (agentScores.isEmpty) {
      throw Exception(
        'No agents available to handle intent: ${request.intent.type.name}',
      );
    }

    // Select agent with highest score
    final sortedAgents = agentScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final selectedAgent = sortedAgents.first.key;
    final selectedScore = sortedAgents.first.value;

    debugPrint(
      '   Selected: ${selectedAgent.name} '
      '(score: ${selectedScore.toStringAsFixed(2)})',
    );
    return selectedAgent;
  }

  /// Calculate score for agent based on intent, context, and capabilities
  Future<double> _calculateAgentScore(Agent agent, AgentRequest request) async {
    var score = 0.0;

    // Base score for capability match
    score += 1.0;

    // Intent-specific scoring
    score += _getIntentScore(agent, request.intent);

    // Context-specific scoring
    score += _getContextScore(agent, request.context);

    // Keyword matching score
    score += _getKeywordScore(agent, request.userMessage);

    // Agent performance score (from metrics)
    score += _getPerformanceScore(agent);

    return score;
  }

  /// Get score based on intent type and agent capabilities
  double _getIntentScore(Agent agent, Intent intent) {
    var score = 0.0;

    // Base score for intent type
    switch (intent.type) {
      case IntentType.consultation:
        if (agent.capabilities.contains(AgentCapabilities.consultation)) {
          score += 2.0;
        }
      case IntentType.analysis:
        if (agent.capabilities.contains(AgentCapabilities.analysis)) {
          score += 2.0;
        }
      case IntentType.generation:
        if (agent.capabilities.contains(AgentCapabilities.textGeneration)) {
          score += 2.0;
        }
      case IntentType.modification:
        if (agent.capabilities.contains(AgentCapabilities.consultation)) {
          score += 1.5;
        }
      case IntentType.unclear:
        score += 0.5; // Lower score for unclear intents
    }

    // Bonus score for specific subtypes
    if (intent.subtype != null) {
      score += _getSubtypeScore(agent, intent.subtype!);
    }

    return score;
  }

  /// Get bonus score for specific intent subtypes
  double _getSubtypeScore(Agent agent, IntentSubtype subtype) {
    switch (subtype) {
      case IntentSubtype.landscapePlanning:
        if (agent.capabilities.contains(AgentCapabilities.landscapeDesign)) {
          return 1.5; // High bonus for landscape planning
        }
        return 0;
      case IntentSubtype.plantSelection:
        if (agent.capabilities.contains(AgentCapabilities.gardening)) {
          return 1.5; // High bonus for plant selection
        }
        return 0;
      case IntentSubtype.constructionAdvice:
        if (agent.capabilities.contains(AgentCapabilities.construction)) {
          return 1.5; // High bonus for construction advice
        }
        return 0;
      case IntentSubtype.maintenanceAdvice:
        if (agent.capabilities.contains(AgentCapabilities.gardening)) {
          return 1; // Bonus for maintenance advice
        }
        return 0;
      case IntentSubtype.generalQuestion:
        return 0.5; // Small bonus for general questions
      case IntentSubtype.imageGeneration:
        if (agent.capabilities.contains(AgentCapabilities.imageGeneration)) {
          return 1; // Bonus for image generation
        }
        return 0;
      case IntentSubtype.textGeneration:
        if (agent.capabilities.contains(AgentCapabilities.textGeneration)) {
          return 1; // Bonus for text generation
        }
        return 0;
      case IntentSubtype.planGeneration:
        if (agent.capabilities.contains(AgentCapabilities.planning)) {
          return 1; // Bonus for planning
        }
        return 0;
      case IntentSubtype.imageAnalysis:
        if (agent.capabilities.contains(AgentCapabilities.imageAnalysis)) {
          return 1; // Bonus for image analysis
        }
        return 0;
      case IntentSubtype.siteAnalysis:
        if (agent.capabilities.contains(AgentCapabilities.analysis)) {
          return 1; // Bonus for site analysis
        }
        return 0;
      case IntentSubtype.problemDiagnosis:
        if (agent.capabilities.contains(AgentCapabilities.analysis)) {
          return 1; // Bonus for problem diagnosis
        }
        return 0;
      case IntentSubtype.designModification:
        if (agent.capabilities.contains(AgentCapabilities.landscapeDesign)) {
          return 1; // Bonus for design modification
        }
        return 0;
      case IntentSubtype.planAdjustment:
        if (agent.capabilities.contains(AgentCapabilities.planning)) {
          return 1; // Bonus for plan adjustment
        }
        return 0;
      case IntentSubtype.contentUpdate:
        return 0.5; // Small bonus for content updates
      case IntentSubtype.ambiguous:
        return 0; // No bonus for ambiguous intents
      case IntentSubtype.incomplete:
        return 0; // No bonus for incomplete intents
    }
  }

  /// Get score based on context (images, conversation history, etc.)
  double _getContextScore(Agent agent, RequestContext context) {
    var score = 0.0;

    // Bonus for agents that can handle images
    if (context.hasImages &&
        agent.capabilities.contains(AgentCapabilities.imageAnalysis)) {
      score += 1.5;
    }

    // Bonus for agents that can handle recent images
    if (context.hasRecentImagesInHistory &&
        agent.capabilities.contains(AgentCapabilities.imageAnalysis)) {
      score += 1.0;
    }

    // Bonus for conversation context
    if (context.conversationLength > 0) {
      score += 0.5;
    }

    return score;
  }

  /// Get score based on keyword matching in user message
  double _getKeywordScore(Agent agent, String userMessage) {
    final message = userMessage.toLowerCase();
    var score = 0.0;

    // Landscape Designer keywords
    if (agent.name.toLowerCase().contains('landscape') ||
        agent.name.toLowerCase().contains('дизайн')) {
      final landscapeKeywords = [
        'участок',
        'преобразовать',
        'дизайн',
        'планировка',
        'зонирование',
        'ландшафт',
        'территория',
        'площадь',
        'размещение',
        'организация',
        'plot',
        'transform',
        'design',
        'planning',
        'zoning',
        'landscape',
      ];

      for (final keyword in landscapeKeywords) {
        if (message.contains(keyword)) {
          score += 1.0;
        }
      }
    }

    // Gardener keywords
    if (agent.name.toLowerCase().contains('gardener') ||
        agent.name.toLowerCase().contains('садовник')) {
      final gardenerKeywords = [
        'растение',
        'цветок',
        'дерево',
        'сад',
        'огород',
        'посадка',
        'уход',
        'полив',
        'удобрение',
        'обрезка',
        'сезон',
        'plant',
        'flower',
        'tree',
        'garden',
        'care',
        'season',
      ];

      for (final keyword in gardenerKeywords) {
        if (message.contains(keyword)) {
          score += 1.0;
        }
      }
    }

    // Builder keywords
    if (agent.name.toLowerCase().contains('builder') ||
        agent.name.toLowerCase().contains('строитель')) {
      final builderKeywords = [
        'строительство',
        'дом',
        'фундамент',
        'материалы',
        'конструкция',
        'building',
        'construction',
        'house',
        'foundation',
        'materials',
      ];

      for (final keyword in builderKeywords) {
        if (message.contains(keyword)) {
          score += 1.0;
        }
      }
    }

    // Ecologist keywords
    if (agent.name.toLowerCase().contains('ecologist') ||
        agent.name.toLowerCase().contains('эколог')) {
      final ecologistKeywords = [
        'экология',
        'экологичный',
        'устойчивый',
        'природный',
        'переработка',
        'ecology',
        'ecological',
        'sustainable',
        'natural',
        'recycling',
      ];

      for (final keyword in ecologistKeywords) {
        if (message.contains(keyword)) {
          score += 1.0;
        }
      }
    }

    return score;
  }

  /// Get score based on agent performance metrics
  double _getPerformanceScore(Agent agent) {
    final metrics = _agentRegistry.getAgentMetrics(agent.id);
    final successRate = metrics['successRate'] as double? ?? 0.5;

    // Convert success rate to score (0.0 to 1.0)
    return successRate;
  }

  /// Get all agents from registry
  List<Agent> _getAllAgents() {
    final agents = _agentRegistry.getAllAgents();
    debugPrint('🔍 Found ${agents.length} agents in registry:');
    for (final agent in agents) {
      debugPrint('   - ${agent.id}: ${agent.name}');
    }
    return agents;
  }

  /// Initialize agent registry with existing agents
  Future<void> _initializeAgentRegistry() async {
    debugPrint('📋 Initializing agent registry...');

    // Register existing agents from AIAgentsConfig using adapters
    final existingAgents = AIAgentsConfig.getAllAgents();

    for (final aiAgent in existingAgents) {
      final agent = AgentAdapter(aiAgent);
      _agentRegistry.registerAgent(agent);
    }

    debugPrint(
      '✅ Agent registry initialized with ${existingAgents.length} agents',
    );
  }

  /// Initialize tool registry with basic tools
  Future<void> _initializeToolRegistry() async {
    debugPrint('🔧 Initializing tool registry...');

    // Tool registration will be implemented in phase 4
    // This placeholder ensures the registry is properly initialized
    // and ready for future tool implementations

    debugPrint('✅ Tool registry initialized (ready for phase 4 tools)');
  }

  /// Get orchestrator status and metrics
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'agentCount': _agentRegistry.agentCount,
      'toolCount': _toolRegistry.toolCount,
      'metrics': _metricsTracker.getMetrics('orchestrator'),
      'registryMetrics': {
        'agents': _agentRegistry.getRegistryMetrics(),
        'tools': _toolRegistry.getRegistryMetrics(),
      },
    };
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    return {
      'orchestrator': _metricsTracker.getMetrics('orchestrator'),
      'summary': _metricsTracker.getSummary(),
      'topPerformers': _metricsTracker.getTopPerformers(limit: 5),
      'slowestComponents': _metricsTracker.getSlowestComponents(limit: 5),
      'componentsWithErrors': _metricsTracker.getComponentsWithErrors(),
    };
  }

  /// Reset all metrics
  void resetMetrics() {
    _metricsTracker.reset();
    _agentRegistry.clearMetrics();
    _toolRegistry.clearMetrics();
    debugPrint('🔄 Reset all orchestrator metrics');
  }

  /// Dispose the orchestrator
  Future<void> dispose() async {
    if (_isInitialized) {
      await _agentRegistry.disposeAllAgents();
      await _toolRegistry.disposeAllTools();
      _isInitialized = false;
      debugPrint('🔒 Agent Orchestrator disposed');
    }
  }
}
