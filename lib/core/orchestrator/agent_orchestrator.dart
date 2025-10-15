/// Agent Orchestrator - Central component for managing agents and requests
///
/// This orchestrator coordinates intent classification, context management,
/// agent selection, and request execution in the system.
library;

// Flutter imports
import 'package:flutter/foundation.dart';

// Third-party package imports
import 'package:uuid/uuid.dart';

// Project imports
import 'package:landcomp_app/core/agents/base/agent.dart';
import 'package:landcomp_app/core/agents/base/agent_adapter.dart';
import 'package:landcomp_app/core/agents/base/agent_registry.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/core/orchestrator/context_manager.dart';
import 'package:landcomp_app/core/orchestrator/intent_classifier.dart';
import 'package:landcomp_app/core/tools/base/tool_registry.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/features/chat/domain/entities/image_generation_response.dart';
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

      // 5. Execute request with intent-aware processing
      final response = await _executeRequestWithIntent(request, agent);

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
        success: response.isSuccess,
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

  /// Execute request with intent-aware processing
  Future<AgentResponse> _executeRequestWithIntent(
    AgentRequest request,
    Agent agent,
  ) async {
    debugPrint('🎯 Executing request with intent: ${request.intent.type.name}');
    
    // Check if this is an image generation request
    if (request.intent.type == IntentType.generation &&
        request.intent.subtype == IntentSubtype.imageGeneration) {
      debugPrint('🎨 Detected image generation intent');
      return await _handleImageGenerationRequest(request, agent);
    }
    
    // Check if this is a generation request based on images
    if (request.intent.imageIntent == ImageIntent.generateBased) {
      debugPrint('🎨 Detected image-based generation intent');
      return await _handleImageGenerationRequest(request, agent);
    }
    
    // Regular request processing
    debugPrint('💬 Processing regular request');
    return await agent.execute(request);
  }

  /// Handle image generation request
  Future<AgentResponse> _handleImageGenerationRequest(
    AgentRequest request,
    Agent agent,
  ) async {
    try {
      debugPrint('🎨 Handling image generation request');
      
      // First, get text response from agent
      final textResponse = await agent.execute(request);
      
      if (!textResponse.isSuccess) {
        return textResponse; // Return error if text generation failed
      }
      
      // Then, generate image based on the request and response
      final imageResponse = await _generateImageForRequest(
        originalMessage: request.userMessage,
        agentResponse: textResponse.message!,
        selectedImages: request.context.attachments,
        agent: agent,
      );
      
      if (imageResponse.hasGeneratedImages) {
        debugPrint('🎨 Successfully generated ${imageResponse.imageCount} image(s)');
        
        // Create attachments from generated images
        final generatedAttachments = <Attachment>[];
        for (int i = 0; i < imageResponse.generatedImages.length; i++) {
          final imageData = imageResponse.generatedImages[i];
          final mimeType = i < imageResponse.imageMimeTypes.length 
              ? imageResponse.imageMimeTypes[i] 
              : 'image/jpeg';
          
          final attachment = Attachment(
            id: _uuid.v4(),
            name: 'generated_design_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            type: AttachmentType.image,
            data: imageData,
            mimeType: mimeType,
            size: imageData.length,
          );
          generatedAttachments.add(attachment);
        }
        
        return AgentResponse.success(
          requestId: request.requestId,
          message: textResponse.message!,
          selectedAgent: textResponse.selectedAgent,
          generatedAttachments: generatedAttachments,
          metadata: {
            ...textResponse.metadata,
            'image_generated': true,
            'image_generation_method': 'orchestrator_intent_based',
            'generated_image_count': imageResponse.imageCount,
          },
        );
      } else {
        debugPrint('🎨 Image generation failed, returning text only');
        return textResponse;
      }
    } catch (e) {
      debugPrint('🎨 Image generation error: $e');
      // Fallback to regular agent execution
      return await agent.execute(request);
    }
  }

  /// Generate image for the request
  Future<ImageGenerationResponse> _generateImageForRequest({
    required String originalMessage,
    required String agentResponse,
    List<Attachment>? selectedImages,
    required Agent agent,
  }) async {
    try {
      // Import AIService here to avoid circular dependency
      final aiService = AIService.instance;
      
      // Build a comprehensive prompt for image generation
      final imagePrompt = _buildImageGenerationPrompt(
        originalMessage: originalMessage,
        agentResponse: agentResponse,
        hasInputImages: selectedImages != null && selectedImages.isNotEmpty,
        agentName: agent.name,
      );
      
      debugPrint('🎨 Image generation prompt: ${imagePrompt.length} characters');
      
      // Prepare input images if available
      final inputImages = <Uint8List>[];
      if (selectedImages != null) {
        for (final attachment in selectedImages) {
          if (attachment.data != null) {
            inputImages.add(attachment.data!);
          }
        }
      }
      
      // Try Gemini first for image generation
      return await aiService.sendImageGenerationToGemini(
        prompt: imagePrompt,
        images: inputImages,
      );
    } catch (e) {
      debugPrint('🎨 Image generation failed: $e');
      return ImageGenerationResponse.textOnly(
        'Image generation failed: $e',
      );
    }
  }

  /// Build comprehensive prompt for image generation
  String _buildImageGenerationPrompt({
    required String originalMessage,
    required String agentResponse,
    required bool hasInputImages,
    required String agentName,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Create a professional landscape design visualization based on the following request:');
    buffer.writeln();
    buffer.writeln('USER REQUEST: $originalMessage');
    buffer.writeln();
    buffer.writeln('DESIGN RECOMMENDATIONS FROM $agentName: $agentResponse');
    buffer.writeln();
    
    if (hasInputImages) {
      buffer.writeln('INSTRUCTIONS:');
      buffer.writeln('- Use the uploaded image as a reference for the existing site');
      buffer.writeln('- Transform the space according to the design recommendations');
      buffer.writeln('- Show the proposed changes and improvements');
      buffer.writeln('- Maintain realistic proportions and scale');
    } else {
      buffer.writeln('INSTRUCTIONS:');
      buffer.writeln('- Create a new landscape design from scratch');
      buffer.writeln('- Follow the design recommendations provided');
      buffer.writeln('- Show a well-planned outdoor space');
      buffer.writeln('- Include appropriate plants, hardscape, and features');
    }
    
    buffer.writeln();
    buffer.writeln('STYLE REQUIREMENTS:');
    buffer.writeln('- Professional landscape design visualization');
    buffer.writeln('- Realistic and detailed');
    buffer.writeln('- Good lighting and composition');
    buffer.writeln('- Clear view of the design elements');
    buffer.writeln('- High quality, suitable for presentation');
    
    return buffer.toString();
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
          final performanceScoreReduced = performanceScore * 0.5;
          debugPrint(
            '     - Intent: ${intentScore.toStringAsFixed(2)}, '
            'Context: ${contextScore.toStringAsFixed(2)}, '
            'Keywords: ${keywordScore.toStringAsFixed(2)}, '
            'Performance: ${performanceScore.toStringAsFixed(2)} (reduced to ${performanceScoreReduced.toStringAsFixed(2)})',
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
    score += _getPerformanceScore(agent) * 0.5;

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

    // Landscape Designer keywords with expanded synonyms
    if (agent.name.toLowerCase().contains('landscape') ||
        agent.name.toLowerCase().contains('дизайн')) {
      final landscapeKeywords = [
        'участок', 'участки', 'участка', 'участком',
        'преобразовать', 'преобразование', 'преобразования', 'преобразуй',
        'дизайн', 'дизайнер', 'дизайна', 'дизайном',
        'планировка', 'планировки', 'планировку', 'планировкой',
        'зонирование', 'зонирования', 'зонированием', 'зоны', 'зону', 'зоной',
        'ландшафт', 'ландшафта', 'ландшафтом', 'ландшафтный',
        'территория', 'территории', 'территорию', 'территорией',
        'площадь', 'площади', 'площадью',
        'размещение', 'размещения', 'размещением', 'разместить', 'размести',
        'организация', 'организации', 'организацию', 'организацией', 'организовать',
        'plot', 'plots', 'transform', 'transformation', 'design', 'designer',
        'planning', 'plan', 'zoning', 'zones', 'landscape', 'landscaping',
      ];

      score += _calculateFuzzyKeywordScore(message, landscapeKeywords);
    }

    // Gardener keywords with expanded synonyms
    if (agent.name.toLowerCase().contains('gardener') ||
        agent.name.toLowerCase().contains('садовник')) {
      final gardenerKeywords = [
        'растение', 'растения', 'растений', 'растением', 'растениями',
        'цветок', 'цветы', 'цветов', 'цветком', 'цветами',
        'дерево', 'деревья', 'деревьев', 'деревом', 'деревьями',
        'сад', 'сада', 'саду', 'садом', 'сады', 'садов',
        'огород', 'огорода', 'огороду', 'огородом', 'огороды', 'огородов',
        'посадка', 'посадки', 'посадку', 'посадкой', 'посадить', 'посади',
        'уход', 'ухода', 'уходом', 'ухаживать', 'ухаживай',
        'полив', 'полива', 'поливом', 'полить', 'поливай',
        'удобрение', 'удобрения', 'удобрением', 'удобрить', 'удобряй',
        'обрезка', 'обрезки', 'обрезку', 'обрезкой', 'обрезать', 'обрезай',
        'сезон', 'сезона', 'сезоном', 'сезоны', 'сезонов',
        
        // Розы и кусты
        'роза', 'розы', 'розовый', 'розовая', 'розовое', 'розовые',
        'куст', 'кусты', 'кустов', 'кустом', 'кустами', 'кустарник', 'кустарники',
        'rose', 'roses', 'bush', 'bushes', 'shrub', 'shrubs',
        
        // Лечение и болезни
        'лечить', 'лечение', 'лечения', 'лечением', 'вылечить', 'вылечи',
        'болезнь', 'болезни', 'болезней', 'болезнью', 'заболевание', 'заболевания',
        'пятна', 'пятен', 'пятном', 'пятнами', 'пятно', 'пятна',
        'листья', 'листьев', 'листом', 'листами', 'лист', 'листа',
        'вредители', 'вредителей', 'вредителем', 'вредителями', 'вредитель',
        'лечение', 'лечения', 'лечением', 'лечить', 'вылечить',
        'disease', 'diseases', 'treatment', 'treat', 'cure', 'heal',
        'pest', 'pests', 'spots', 'spot', 'leaves', 'leaf',
        
        'plant', 'plants', 'flower', 'flowers', 'tree', 'trees',
        'garden', 'gardens', 'care', 'caring', 'season', 'seasons',
      ];

      score += _calculateFuzzyKeywordScore(message, gardenerKeywords);
    }

    // Builder keywords with expanded synonyms and related terms
    if (agent.name.toLowerCase().contains('builder') ||
        agent.name.toLowerCase().contains('строитель')) {
      final builderKeywords = [
        'строительство', 'строительства', 'строительством', 'строить', 'строи',
        'дом', 'дома', 'домов', 'домом', 'домами', 'домик', 'домика', 'домиком',
        'фундамент', 'фундамента', 'фундаментом', 'фундаменты', 'фундаментов',
        'материалы', 'материалов', 'материалом', 'материалами', 'материал', 'материала',
        'строительные материалы', 'строительных материалов', 'строительным материалом',
        'конструкция', 'конструкции', 'конструкцию', 'конструкцией', 'конструкции',
        'построить', 'построить', 'построй', 'постройка', 'постройки', 'постройку',
        'здание', 'здания', 'зданий', 'зданием', 'зданиями',
        'сооружение', 'сооружения', 'сооружений', 'сооружением', 'сооружениями',
        'стены', 'стен', 'стеной', 'стенами', 'стена', 'стены',
        'крыша', 'крыши', 'крыш', 'крышей', 'крышами',
        'пол', 'пола', 'полом', 'полами', 'полы', 'полов',
        'building', 'buildings', 'construction', 'construct', 'house', 'houses',
        'foundation', 'foundations', 'materials', 'material', 'structure', 'structures',
        'build', 'built', 'builds', 'building', 'construct', 'constructed',
      ];

      score += _calculateFuzzyKeywordScore(message, builderKeywords);
    }

    // Ecologist keywords with expanded synonyms
    if (agent.name.toLowerCase().contains('ecologist') ||
        agent.name.toLowerCase().contains('эколог')) {
      final ecologistKeywords = [
        'экология', 'экологии', 'экологией', 'экологический', 'экологическая',
        'экологичный', 'экологичная', 'экологичного', 'экологичной',
        'устойчивый', 'устойчивая', 'устойчивого', 'устойчивой', 'устойчивость',
        'природный', 'природная', 'природного', 'природной', 'природа', 'природы',
        'переработка', 'переработки', 'переработку', 'переработкой', 'переработать',
        'отходы', 'отходов', 'отходами', 'отход', 'отхода',
        'компост', 'компоста', 'компостом', 'компостировать',
        'био', 'биологический', 'биологическая', 'биологического', 'биологической',
        'органический', 'органическая', 'органического', 'органической',
        'натуральный', 'натуральная', 'натурального', 'натуральной',
        'ecology', 'ecological', 'ecologically', 'sustainable', 'sustainability',
        'natural', 'naturally', 'recycling', 'recycle', 'waste', 'compost',
        'organic', 'organically', 'bio', 'biological', 'biologically',
      ];

      score += _calculateFuzzyKeywordScore(message, ecologistKeywords);
    }

    return score;
  }

  /// Calculate fuzzy keyword score with typo tolerance and partial matching
  double _calculateFuzzyKeywordScore(String message, List<String> keywords) {
    var totalScore = 0.0;
    final matchedKeywords = <String>[];

    for (final keyword in keywords) {
      final keywordLower = keyword.toLowerCase();
      
      // Exact match - highest score
      if (message.contains(keywordLower)) {
        totalScore += 1.0;
        matchedKeywords.add(keyword);
        continue;
      }

      // Check for partial matches and typos
      final matchScore = _calculateFuzzyMatch(message, keywordLower);
      if (matchScore > 0.0) {
        totalScore += matchScore;
        matchedKeywords.add('$keyword (fuzzy: ${(matchScore * 100).toInt()}%)');
      }
    }

    // Log matched keywords for debugging
    if (matchedKeywords.isNotEmpty) {
      debugPrint('     - Matched keywords: ${matchedKeywords.join(', ')}');
    }

    return totalScore;
  }

  /// Calculate fuzzy match score between message and keyword
  double _calculateFuzzyMatch(String message, String keyword) {
    // Split message into words
    final words = message.split(RegExp(r'\s+'));
    
    for (final word in words) {
      // Skip very short words
      if (word.length < 3) continue;
      
      // Check for partial matches (keyword contains word or vice versa)
      if (keyword.contains(word) || word.contains(keyword)) {
        final similarity = _calculateSimilarity(word, keyword);
        if (similarity >= 0.7) {
          return similarity * 0.8; // Partial match gets 80% of similarity score
        }
      }
      
      // Check for typo tolerance using Levenshtein distance
      if (word.length >= 4 && keyword.length >= 4) {
        final similarity = _calculateSimilarity(word, keyword);
        if (similarity >= 0.8) {
          return similarity * 0.6; // Typo match gets 60% of similarity score
        }
      }
    }
    
    return 0.0;
  }

  /// Calculate similarity between two strings using Levenshtein distance
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
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
