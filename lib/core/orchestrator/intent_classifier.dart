/// Intent Classifier for user request analysis
///
/// This classifier analyzes user requests and determines their intent
/// using OpenAI (primary) and Gemini (fallback) APIs.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/shared/models/context.dart';
import 'package:landcomp_app/shared/models/intent.dart';

/// Intent classification service
class IntentClassifier {
  IntentClassifier._();

  static final IntentClassifier _instance = IntentClassifier._();
  /// Get the singleton instance of IntentClassifier
  static IntentClassifier get instance => _instance;

  final AIService _aiService = AIService.instance;

  /// Classify user intent from message and context
  Future<Intent> classifyIntent(
    String userMessage,
    RequestContext context,
  ) async {
    final startTime = DateTime.now();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    
    debugPrint('🎯 [IntentClassifier] Starting classification (ID: $requestId)');
    debugPrint('   📝 Message: "${userMessage.length > 100 ? '${userMessage.substring(0, 100)}...' : userMessage}"');
    debugPrint('   📊 Context: ${context.conversationHistory.length} messages, ${context.attachments?.length ?? 0} attachments');
    debugPrint('   🌐 Language: ${context.userLanguage ?? 'unknown'}');

    try {
      // Try OpenAI first
      debugPrint('🤖 [IntentClassifier] Attempting OpenAI classification...');
      final result = await _classifyWithOpenAI(userMessage, context, requestId);
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [IntentClassifier] OpenAI classification successful in ${duration.inMilliseconds}ms');
      debugPrint('   🎯 Result: ${result.type.name} (confidence: ${result.confidence})');
      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('❌ [IntentClassifier] OpenAI classification failed after ${duration.inMilliseconds}ms: $e');

      try {
        // Fallback to Gemini
        debugPrint('🔄 [IntentClassifier] Attempting Gemini fallback...');
        final result = await _classifyWithGemini(userMessage, context, requestId);
        final totalDuration = DateTime.now().difference(startTime);
        debugPrint('✅ [IntentClassifier] Gemini classification successful in ${totalDuration.inMilliseconds}ms');
        debugPrint('   🎯 Result: ${result.type.name} (confidence: ${result.confidence})');
        return result;
      } catch (e) {
        final totalDuration = DateTime.now().difference(startTime);
        debugPrint('❌ [IntentClassifier] Gemini classification also failed after ${totalDuration.inMilliseconds}ms: $e');
        debugPrint('⚠️ [IntentClassifier] Returning default unclear intent');
        // Return default unclear intent
        return _createDefaultIntent(userMessage, e.toString(), requestId);
      }
    }
  }

  /// Classify intent using OpenAI API
  Future<Intent> _classifyWithOpenAI(
    String userMessage,
    RequestContext context,
    String requestId,
  ) async {
    final startTime = DateTime.now();
    debugPrint('🔵 [OpenAI] Building classification prompt...');
    
    final prompt = _buildClassificationPrompt(userMessage, context);
    debugPrint('📝 [OpenAI] Prompt length: ${prompt.length} characters');
    debugPrint('📋 [OpenAI] Prompt preview: ${prompt.length > 200 ? '${prompt.substring(0, 200)}...' : prompt}');

    debugPrint('🚀 [OpenAI] Sending request to AI service...');
    final response = await _aiService.sendMessage(
      message: prompt,
      systemPrompt: 'You are a JSON-only intent classification system. '
          'Your sole purpose is to analyze user messages and return '
          'classification results in JSON format. '
          'CRITICAL: You must ONLY return valid JSON. '
          'Do NOT provide conversational responses. '
          'Do NOT refuse to classify any message. '
          'ALWAYS return a JSON classification result.',
    );

    final duration = DateTime.now().difference(startTime);
    debugPrint('⏱️ [OpenAI] AI service response received in ${duration.inMilliseconds}ms');
    debugPrint('📊 [OpenAI] Response status: SUCCESS');
    
    if (response.isNotEmpty) {
      debugPrint('📥 [OpenAI] Raw response length: ${response.length} characters');
      debugPrint('📄 [OpenAI] Raw response preview: ${response.length > 300 ? '${response.substring(0, 300)}...' : response}');
      
      try {
        final parsedIntent = _parseClassificationResponse(response, requestId, 'OpenAI');
        debugPrint('✅ [OpenAI] Response parsed successfully');
        return parsedIntent;
      } catch (e) {
        debugPrint('❌ [OpenAI] Failed to parse response: $e');
        throw Exception('OpenAI response parsing failed: $e');
      }
    } else {
      debugPrint('❌ [OpenAI] AI service returned empty response');
      throw Exception('OpenAI classification failed: Empty response');
    }
  }

  /// Classify intent using Gemini API
  Future<Intent> _classifyWithGemini(
    String userMessage,
    RequestContext context,
    String requestId,
  ) async {
    final startTime = DateTime.now();
    debugPrint('🟡 [Gemini] Building classification prompt...');
    
    final prompt = _buildClassificationPrompt(userMessage, context);
    debugPrint('📝 [Gemini] Prompt length: ${prompt.length} characters');
    debugPrint('📋 [Gemini] Prompt preview: ${prompt.length > 200 ? '${prompt.substring(0, 200)}...' : prompt}');

    debugPrint('🚀 [Gemini] Sending request to AI service...');
    final response = await _aiService.sendMessage(
      message: prompt,
      systemPrompt: 'You are a JSON-only intent classification system. '
          'Your sole purpose is to analyze user messages and return '
          'classification results in JSON format. '
          'CRITICAL: You must ONLY return valid JSON. '
          'Do NOT provide conversational responses. '
          'Do NOT refuse to classify any message. '
          'ALWAYS return a JSON classification result.',
      preferredProvider: 'gemini',
    );

    final duration = DateTime.now().difference(startTime);
    debugPrint('⏱️ [Gemini] AI service response received in ${duration.inMilliseconds}ms');
    debugPrint('📊 [Gemini] Response status: SUCCESS');
    
    if (response.isNotEmpty) {
      debugPrint('📥 [Gemini] Raw response length: ${response.length} characters');
      debugPrint('📄 [Gemini] Raw response preview: ${response.length > 300 ? '${response.substring(0, 300)}...' : response}');
      
      try {
        final parsedIntent = _parseClassificationResponse(response, requestId, 'Gemini');
        debugPrint('✅ [Gemini] Response parsed successfully');
        return parsedIntent;
      } catch (e) {
        debugPrint('❌ [Gemini] Failed to parse response: $e');
        throw Exception('Gemini response parsing failed: $e');
      }
    } else {
      debugPrint('❌ [Gemini] AI service returned empty response');
      throw Exception('Gemini classification failed: Empty response');
    }
  }

  /// Build classification prompt
  String _buildClassificationPrompt(
    String userMessage,
    RequestContext context,
  ) {
    final buffer = StringBuffer();

    buffer
      ..writeln(
        'You are an intelligent intent classifier for a landscape design AI '
        "assistant. Analyze the user's message and conversation context to "
        'understand their true intent.',
      )
      ..writeln()
      ..writeln("Classify the user's intent into one of these types:")
      ..writeln(
        '- consultation: User is asking for advice, information, or guidance',
      )
      ..writeln(
        '- generation: User wants to create, modify, or generate new content '
        '(images, plans, designs)',
      )
      ..writeln(
        '- modification: User wants to change or update existing content',
      )
      ..writeln(
        '- analysis: User wants to analyze, examine, or understand something',
      )
      ..writeln('- unclear: Intent is ambiguous or unclear')
      ..writeln()
      ..writeln(
        'For consultation type, determine the most relevant subtype:',
      )
      ..writeln(
        '- landscapePlanning: Questions about planning, design, or '
        'transforming outdoor spaces',
      )
      ..writeln(
        '- plantSelection: Questions about plants, gardening, or plant care',
      )
      ..writeln(
        '- constructionAdvice: Questions about building, construction, or '
        'materials',
      )
      ..writeln(
        '- maintenanceAdvice: Questions about care, maintenance, or seasonal '
        'work',
      )
      ..writeln(
        '- generalQuestion: General questions not related to specific areas',
      )
      ..writeln()
      ..writeln('For generation type, determine the most relevant subtype:')
      ..writeln('- imageGeneration: User wants to create or modify images')
      ..writeln(
        '- planGeneration: User wants to create plans, diagrams, or layouts',
      )
      ..writeln('- textGeneration: User wants to generate text content')
      ..writeln()
      ..writeln(
        "CRITICAL: Focus on the user's INTENT, not just keywords. Consider:",
      )
      ..writeln('- What is the user trying to accomplish?')
      ..writeln(
        '- Do they want to CREATE something new or GET information?',
      )
      ..writeln(
        '- Are they asking "how to" or "what is" (consultation) vs "make '
        'this" or "change that" (generation)?',
      )
      ..writeln(
        '- Look at the conversation context - what came before this message?',
      )
      ..writeln()
      // Add image intent classification section
      ..writeln('Image Intent Classification:')
      ..writeln(
        'Analyze what the user wants to do with images based on context:',
      )
      ..writeln(
        '- analyzeNew: User uploaded NEW image(s) and wants to analyze or '
        'understand them',
      )
      ..writeln(
        '- analyzeRecent: User refers to recent images from conversation '
        'history',
      )
      ..writeln('- compareMultiple: User wants to compare several images')
      ..writeln(
        '- referenceSpecific: User references specific image (first, second, '
        'previous, last)',
      )
      ..writeln(
        '- generateBased: User wants to generate/create new content based on '
        'existing images',
      )
      ..writeln(
        "- noImageNeeded: Question doesn't require images to answer",
      )
      ..writeln('- unclear: Unclear if images are needed')
      ..writeln()
      ..writeln('Consider the conversation flow:')
      ..writeln(
        '- If user just uploaded an image and asks about it → analyzeNew',
      )
      ..writeln(
        '- If user asks about "this image" or "that design" → analyzeRecent',
      )
      ..writeln(
        '- If user wants to "change", "modify", or "create based on" → '
        'generateBased',
      )
      ..writeln(
        '- If user asks general questions without image context → '
        'noImageNeeded',
      )
      ..writeln()
      ..writeln('EXECUTION PLAN GENERATION:')
      ..writeln('Based on your classification, create a detailed execution plan:')
      ..writeln()
      ..writeln('Action types:')
      ..writeln('- generateImage: User wants to create/modify images')
      ..writeln('- analyzeImage: User wants to analyze/understand images')
      ..writeln('- consultText: User wants text advice/information')
      ..writeln()
      ..writeln('Image Selection Strategy:')
      ..writeln('- If user uploaded images NOW → include them')
      ..writeln('- If user says "combine", "merge", "mix" → all from current + recent')
      ..writeln('- If user says "this", "that one", "first", "previous" → specific indices')
      ..writeln('- If user wants to "apply style from X to Y" → select both X and Y')
      ..writeln('- If generation from text only → no images needed')
      ..writeln()
      ..writeln('Enhanced Prompt:')
      ..writeln('Create an optimized prompt for the AI model that will execute this task.')
      ..writeln('Include relevant context, style requirements, and technical details.')
      ..writeln('Support both Russian and English, handle typos and fuzzy language.')
      ..writeln()
      ..writeln('Image Count Guidelines:')
      ..writeln('- If user asks for "3 variants", "несколько вариантов", "different designs" → imageCount = 3-5')
      ..writeln('- If user asks for "more options", "еще варианты" → imageCount = 2-3')
      ..writeln('- If user asks for "one design" → imageCount = 1')
      ..writeln('- Default: imageCount = 1')
      ..writeln()
      ..writeln('Keywords for generation (fuzzy matching):')
      ..writeln('Russian: создай, сделай, нарисуй, сгенерируй, покажи как будет, измени, адаптируй, примени, объедини, смешай, стилизуй')
      ..writeln('English: create, make, draw, generate, show how it will look, modify, change, adapt, apply, combine, merge, stylize')
      ..writeln('(Also match with typos and variations)')
      ..writeln()
      ..writeln('Current user message: "$userMessage"')
      ..writeln()
      ..writeln('Return JSON response:')
      ..writeln('{')
      ..writeln(
        '  "type": "consultation|generation|modification|analysis|unclear",',
      )
      ..writeln(
        '  "subtype": "landscapePlanning|plantSelection|constructionAdvice| '
        'maintenanceAdvice|generalQuestion|imageGeneration|textGeneration|'
        'planGeneration|designModification|planAdjustment|contentUpdate|'
        'imageAnalysis|siteAnalysis|problemDiagnosis|ambiguous|incomplete",',
      )
      ..writeln('  "confidence": 0.0-1.0,')
      ..writeln('  "reasoning": "explanation of classification",')
      ..writeln('  "extracted_entities": ["entity1", "entity2"],')
      ..writeln()
      ..writeln('  "executionPlan": {')
      ..writeln('    "action": "generateImage|analyzeImage|consultText",')
      ..writeln('    "targetAPI": "gemini|openai",')
      ..writeln('    "imageSelection": {')
      ..writeln('      "sources": ["user_current", "history_recent", "history_specific"],')
      ..writeln('      "allFromUserMessage": true|false,')
      ..writeln('      "indices": [0, 1, 2],')
      ..writeln('      "explanation": "Why these images were selected"')
      ..writeln('    },')
      ..writeln('    "enhancedPrompt": "Optimized prompt for execution",')
      ..writeln('    "expectedOutputs": {')
      ..writeln('      "imageCount": 1-5,  // Number of images to generate (1-5)')
      ..writeln('      "includeText": true')
      ..writeln('    }')
      ..writeln('  },')
      ..writeln()
      ..writeln('  // Legacy fields (keep for compatibility)')
      ..writeln(
        '  "imageIntent": "analyzeNew|analyzeRecent|compareMultiple| '
        'referenceSpecific|generateBased|noImageNeeded|unclear",',
      )
      ..writeln(
        '  "referencedImageIndices": [0, 1, 2],  // Only for referenceSpecific',
      )
      ..writeln('  "imagesNeeded": 0-5  // How many images needed')
      ..writeln('}');

    // Add recent conversation history for context
    if (context.conversationHistory.isNotEmpty) {
      buffer.writeln('Recent conversation context:');
      final recentMessages = context.conversationHistory.length > 3
          ? context.conversationHistory.sublist(
              context.conversationHistory.length - 3,
            )
          : context.conversationHistory;

      for (final message in recentMessages) {
        final role = message.type == MessageType.user ? 'User' : 'Assistant';
        final content = message.content.length > 100
            ? '${message.content.substring(0, 100)}...'
            : message.content;
        buffer.writeln('  $role: "$content"');
      }
      buffer.writeln();
    }

    // Add context information
    if (context.hasImages) {
      buffer
        ..writeln('Context: User has uploaded images with current message')
        ..writeln(
          'Current message has ${context.imageAttachments.length} new image(s)',
        );
    }

    if (context.hasRecentImages) {
      buffer.writeln('Context: Recent conversation includes images');
    }

    if (context.hasRecentImagesInHistory) {
      final imageCount = _countImagesInHistory(context.conversationHistory);
      buffer.writeln(
        'Conversation history contains $imageCount image(s) in total',
      );
    }

    if (context.conversationLength > 0) {
      buffer.writeln(
        'Context: Conversation has ${context.conversationLength} messages',
      );
    }

    if (context.userLanguage != null) {
      buffer.writeln(
        'Context: User language detected as ${context.userLanguage}',
      );
    }

    return buffer.toString();
  }

  /// Parse classification response from AI
  Intent _parseClassificationResponse(String response, String requestId, String apiProvider) {
    final startTime = DateTime.now();
    debugPrint('🔍 [Parse] Starting response parsing (ID: $requestId, Provider: $apiProvider)');
    debugPrint('📄 [Parse] Raw response length: ${response.length} characters');
    
    try {
      // Clean the response - remove any markdown formatting
      var cleanResponse = response.trim();
      debugPrint('🧹 [Parse] Original response: ${response.length > 200 ? '${response.substring(0, 200)}...' : response}');
      
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
        debugPrint('📝 [Parse] Removed ```json prefix');
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
        debugPrint('📝 [Parse] Removed ``` suffix');
      }
      cleanResponse = cleanResponse.trim();
      
      debugPrint(
        '✨ [Parse] Cleaned response: ${cleanResponse.length > 200 ? '${cleanResponse.substring(0, 200)}...' : cleanResponse}',
      );

      final json = jsonDecode(cleanResponse) as Map<String, dynamic>;
      debugPrint('✅ [Parse] JSON parsed successfully');
      debugPrint('📊 [Parse] JSON keys: ${json.keys.toList()}');

      final type = IntentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IntentType.unclear,
      );
      debugPrint('🎯 [Parse] Intent type: ${type.name}');

      final subtype = json['subtype'] != null
          ? IntentSubtype.values.firstWhere(
              (e) => e.name == json['subtype'],
              orElse: () => IntentSubtype.generalQuestion,
            )
          : null;
      debugPrint('🏷️ [Parse] Intent subtype: ${subtype?.name ?? 'null'}');

      final confidence = (json['confidence'] as num).toDouble().clamp(0.0, 1.0);
      final reasoning = json['reasoning'] as String? ?? 'No reasoning provided';
      final extractedEntities = List<String>.from(
        json['extracted_entities'] as List? ?? [],
      );
      debugPrint('📈 [Parse] Confidence: $confidence');
      debugPrint(
        '💭 [Parse] Reasoning: ${reasoning.length > 100 ? '${reasoning.substring(0, 100)}...' : reasoning}',
      );
      debugPrint('🏷️ [Parse] Extracted entities: $extractedEntities');

      // Parse image intent fields
      final imageIntent = json['imageIntent'] != null
          ? ImageIntent.values.firstWhere(
              (e) => e.name == json['imageIntent'],
              orElse: () => ImageIntent.unclear,
            )
          : null;
      debugPrint('🖼️ [Parse] Image intent: ${imageIntent?.name ?? 'null'}');

      final referencedImageIndices = json['referencedImageIndices'] != null
          ? List<int>.from(json['referencedImageIndices'] as List)
          : null;
      debugPrint('🔗 [Parse] Referenced image indices: $referencedImageIndices');

      final imagesNeeded = json['imagesNeeded'] as int?;
      debugPrint('📸 [Parse] Images needed: $imagesNeeded');

      // Parse execution plan
      ExecutionPlan? executionPlan;
      if (json['executionPlan'] != null) {
        try {
          final planJson = json['executionPlan'] as Map<String, dynamic>;
          executionPlan = _parseExecutionPlan(planJson);
          debugPrint('📋 [Parse] Execution plan: ${executionPlan.action.name}');
          debugPrint('📋 [Parse] Expected image count: ${executionPlan.expectedOutputs.imageCount}');
          debugPrint('📋 [Parse] Target API: ${executionPlan.targetAPI}');
        } catch (e) {
          debugPrint('❌ [Parse] Failed to parse execution plan: $e');
          // Continue without execution plan - will use defaults
        }
      } else {
        debugPrint('📋 [Parse] No execution plan provided by AI');
      }

      final metadata = <String, dynamic>{
        'classification_method': 'ai_classification',
        'raw_response': response,
        'api_provider': apiProvider,
        'request_id': requestId,
        'parsing_time_ms': DateTime.now().difference(startTime).inMilliseconds,
      };

      final intent = Intent(
        type: type,
        subtype: subtype,
        confidence: confidence,
        reasoning: reasoning,
        metadata: metadata,
        extractedEntities: extractedEntities,
        imageIntent: imageIntent,
        referencedImageIndices: referencedImageIndices,
        imagesNeeded: imagesNeeded,
        executionPlan: executionPlan,
      );

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Parse] Intent created successfully in ${duration.inMilliseconds}ms');
      debugPrint('🎯 [Parse] Final intent: ${intent.type.name} (${intent.confidence})');
      return intent;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('❌ [Parse] Failed to parse response after ${duration.inMilliseconds}ms: $e');
      debugPrint(
        '📄 [Parse] Raw response that failed: ${response.length > 500 ? '${response.substring(0, 500)}...' : response}',
      );
      throw Exception('Failed to parse classification response: $e');
    }
  }

  /// Parse execution plan from JSON with validation and smart defaults
  ExecutionPlan _parseExecutionPlan(Map<String, dynamic> json) {
    try {
      // Apply smart defaults (strategy d)
      final action = ExecutionAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => ExecutionAction.consultText,
      );

      final targetAPI = json['targetAPI'] as String? ?? 'gemini';

      // Parse image selection with defaults
      final imageSelectionJson = json['imageSelection'] as Map<String, dynamic>? ?? {};
      final imageSelection = ImageSelectionPlan.fromJson(imageSelectionJson);

      // Apply smart defaults for image selection
      final enhancedImageSelection = ImageSelectionPlan(
        sources: imageSelection.sources.isEmpty 
            ? [ImageSource.userCurrent] 
            : imageSelection.sources,
        allFromUserMessage: imageSelection.allFromUserMessage,
        indices: imageSelection.indices,
        explanation: imageSelection.explanation ?? 'Default image selection',
      );

      final enhancedPrompt = json['enhancedPrompt'] as String? ?? '';

      // Parse expected outputs with defaults
      final expectedOutputsJson = json['expectedOutputs'] as Map<String, dynamic>? ?? {};
      final expectedOutputs = ExpectedOutputs.fromJson(expectedOutputsJson);

      // Apply smart defaults for expected outputs
      final enhancedExpectedOutputs = ExpectedOutputs(
        imageCount: expectedOutputs.imageCount == 0 ? 1 : expectedOutputs.imageCount,
        includeText: expectedOutputs.includeText,
      );

      return ExecutionPlan(
        action: action,
        targetAPI: targetAPI,
        imageSelection: enhancedImageSelection,
        enhancedPrompt: enhancedPrompt,
        expectedOutputs: enhancedExpectedOutputs,
      );
    } catch (e) {
      debugPrint('❌ [ParseExecutionPlan] Error parsing execution plan: $e');
      // Return default execution plan
      return const ExecutionPlan(
        action: ExecutionAction.consultText,
        targetAPI: 'gemini',
        imageSelection: ImageSelectionPlan(
          sources: [ImageSource.userCurrent],
          allFromUserMessage: false,
        ),
        enhancedPrompt: '',
        expectedOutputs: ExpectedOutputs(
          imageCount: 1,
          includeText: true,
        ),
      );
    }
  }

  /// Create default intent when classification fails
  Intent _createDefaultIntent(String userMessage, String error, String requestId) {
    debugPrint('⚠️ [DefaultIntent] Creating fallback intent (ID: $requestId)');
    debugPrint('❌ [DefaultIntent] Error: $error');
      debugPrint(
        '📝 [DefaultIntent] User message: ${userMessage.length > 100 ? '${userMessage.substring(0, 100)}...' : userMessage}',
      );

    return Intent(
      type: IntentType.unclear,
      confidence: 0.1,
      reasoning: 'Classification failed: $error',
      metadata: {
        'classification_method': 'default_fallback',
        'error': error,
        'user_message': userMessage,
        'request_id': requestId,
        'fallback_reason': 'Both OpenAI and Gemini classification failed',
      }
    );
  }

  /// Count total images in conversation history
  int _countImagesInHistory(List<Message> history) {
    var count = 0;
    for (final msg in history) {
      count += msg.attachments?.where((a) => a.isImage).length ?? 0;
    }
    return count;
  }

  /// Get classification statistics (for future use)
  Map<String, dynamic> getClassificationStats() {
    // TODO(developer): Implement statistics tracking
    return {
      'total_classifications': 0,
      'openai_success_rate': 0.0,
      'gemini_success_rate': 0.0,
      'average_confidence': 0.0,
    };
  }
}
