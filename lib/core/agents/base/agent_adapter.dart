/// Agent Adapter for wrapping existing AIAgent entities
///
/// This is a temporary adapter to make existing AIAgent entities work
/// with the new Agent interface until proper Agent implementations are created.
library;

import 'package:landcomp_app/core/agents/base/agent.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';
import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/agent_request.dart';
import 'package:landcomp_app/shared/models/agent_response.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';

/// Adapter that wraps AIAgent to implement Agent interface
class AgentAdapter implements Agent {
  /// Create adapter from AIAgent
  AgentAdapter(this._aiAgent);

  final AIAgent _aiAgent;
  final AIService _aiService = AIService.instance;
  List<String>? _cachedCapabilities; // Cache capabilities

  @override
  String get id => _aiAgent.id;

  @override
  String get name => _aiAgent.name;

  @override
  List<String> get capabilities {
    // Return cached capabilities if available
    if (_cachedCapabilities != null) {
      return _cachedCapabilities!;
    }

    print('🔍 Building capabilities for ${_aiAgent.name}');

    // Map AIAgent expertise areas to capabilities
    final capabilities = <String>[];

    for (final area in _aiAgent.expertiseAreas) {
      final lowerArea = area.toLowerCase();
      switch (lowerArea) {
        case 'plant selection':
        case 'garden care':
        case 'seasonal work':
        case 'pest control':
        case 'organic farming':
        case 'gardening':
        case 'plants':
        case 'flowers':
        case 'trees':
          capabilities.add(AgentCapabilities.gardening);
        case 'site planning':
        case 'zoning':
        case 'garden paths':
        case 'recreation areas':
        case 'landscape materials':
        case 'landscape design':
        case 'planning':
        case 'design':
          capabilities.add(AgentCapabilities.landscapeDesign);
          capabilities.add(AgentCapabilities.planning);
        case 'foundations':
        case 'walls and floors':
        case 'roofing':
        case 'utilities':
        case 'cost estimation':
        case 'construction':
        case 'building':
        case 'materials':
          capabilities.add(AgentCapabilities.construction);
        case 'eco materials':
        case 'energy saving':
        case 'waste recycling':
        case 'water conservation':
        case 'ecosystems':
        case 'ecology':
        case 'sustainability':
        case 'environmental':
          capabilities.add(AgentCapabilities.ecology);
        case 'image analysis':
        case 'visual analysis':
        case 'photo analysis':
          capabilities.add(AgentCapabilities.imageAnalysis);
        case 'image generation':
        case 'visual generation':
        case 'photo generation':
          capabilities.add(AgentCapabilities.imageGeneration);
      }
    }

    // Add specific capabilities based on agent name
    final agentName = _aiAgent.name.toLowerCase();
    if (agentName.contains('landscape') || agentName.contains('дизайн')) {
      capabilities.add(AgentCapabilities.landscapeDesign);
      capabilities.add(AgentCapabilities.planning);
    }
    if (agentName.contains('gardener') || agentName.contains('садовник')) {
      capabilities.add(AgentCapabilities.gardening);
    }
    if (agentName.contains('builder') || agentName.contains('строитель')) {
      capabilities.add(AgentCapabilities.construction);
    }
    if (agentName.contains('ecologist') || agentName.contains('эколог')) {
      capabilities.add(AgentCapabilities.ecology);
    }

    // Add common capabilities
    capabilities.addAll([
      AgentCapabilities.textGeneration,
      AgentCapabilities.consultation,
      AgentCapabilities.analysis,
    ]);

    // Cache and remove duplicates - IMPORTANT: create the list once and reuse it
    final uniqueCapabilities = capabilities.toSet().toList();
    _cachedCapabilities = uniqueCapabilities;
    print('   Final capabilities: $_cachedCapabilities');
    return _cachedCapabilities!;
  }

  @override
  Future<bool> canHandle(Intent intent, RequestContext context) async {
    // Enhanced capability-based matching with subtype consideration
    var canHandle = false;

    // Check base intent type
    switch (intent.type) {
      case IntentType.consultation:
        canHandle = capabilities.contains(AgentCapabilities.consultation);
      case IntentType.analysis:
        canHandle = capabilities.contains(AgentCapabilities.analysis);
      case IntentType.generation:
        canHandle = capabilities.contains(AgentCapabilities.textGeneration);
      case IntentType.modification:
        canHandle = capabilities.contains(AgentCapabilities.consultation);
      case IntentType.unclear:
        canHandle = true; // All agents can handle unclear intents
    }

    print(
      '   🔍 ${_aiAgent.name}: base intent ${intent.type.name} -> $canHandle',
    );

    // If base intent is handled, check subtype-specific capabilities
    if (canHandle && intent.subtype != null) {
      final subtypeResult = _canHandleSubtype(intent.subtype!);
      print(
        '   🔍 ${_aiAgent.name}: subtype ${intent.subtype!.name} -> $subtypeResult',
      );
      canHandle = subtypeResult;
    }

    // Note: We don't block agents based on image presence
    // Image analysis capability is a bonus in scoring, not a requirement

    print('   🔍 ${_aiAgent.name}: final canHandle = $canHandle');
    return canHandle;
  }

  /// Check if agent can handle specific intent subtype
  bool _canHandleSubtype(IntentSubtype subtype) {
    switch (subtype) {
      case IntentSubtype.landscapePlanning:
        return capabilities.contains(AgentCapabilities.landscapeDesign) ||
            capabilities.contains(AgentCapabilities.planning);
      case IntentSubtype.plantSelection:
        return capabilities.contains(AgentCapabilities.gardening);
      case IntentSubtype.constructionAdvice:
        return capabilities.contains(AgentCapabilities.construction);
      case IntentSubtype.imageAnalysis:
        return capabilities.contains(AgentCapabilities.imageAnalysis);
      case IntentSubtype.imageGeneration:
        return capabilities.contains(AgentCapabilities.imageGeneration);
      case IntentSubtype.planGeneration:
        return capabilities.contains(AgentCapabilities.planning);
      default:
        return true; // Default to true for other subtypes
    }
  }

  @override
  Future<AgentResponse> execute(AgentRequest request) async {
    print('🤖 Executing request with agent: ${_aiAgent.name}');

    try {
      // ALWAYS use sendMessageWithSmartSelection for full conversation context
      // It handles both text-only and image requests properly with full history
      print(
        '📸 Request has ${request.context.attachments?.length ?? 0} attachments',
      );
      print(
        '📚 Conversation history: ${request.conversationHistory.length} messages',
      );

      final response = await _aiService.sendMessageWithSmartSelection(
        message: request.userMessage,
        conversationHistory: request.conversationHistory.cast<Message>(),
        selectedImages: request.context.attachments,
      );

      if (response.isSuccess && response.message != null) {
        return AgentResponse.success(
          requestId: request.requestId,
          message: response.message!,
          selectedAgent: _aiAgent,
          metadata: {
            'confidence': response.confidence ?? 0.8,
            'execution_method': 'ai_service_smart_selection',
            'has_images': request.context.hasImages,
            'history_length': request.conversationHistory.length,
          },
        );
      } else {
        return AgentResponse.error(
          requestId: request.requestId,
          error: response.message ?? 'Unknown error from AI service',
          metadata: const {'execution_method': 'ai_service_smart_selection'},
        );
      }
    } catch (e) {
      return AgentResponse.error(
        requestId: request.requestId,
        error: 'Agent execution failed: $e',
        metadata: {
          'execution_method': 'ai_service_adapter',
          'error_type': e.runtimeType.toString(),
        },
      );
    }
  }

  @override
  Map<String, dynamic> getMetrics() {
    return {
      'agent_id': id,
      'agent_name': name,
      'capabilities': capabilities,
      'expertise_areas': _aiAgent.expertiseAreas,
      'is_active': _aiAgent.isActive,
    };
  }

  @override
  Future<void> initialize() async {
    // No initialization needed for adapter
  }

  @override
  Future<void> dispose() async {
    // No disposal needed for adapter
  }
}
