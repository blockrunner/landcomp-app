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
      
      debugPrint('✨ [Parse] Cleaned response: ${cleanResponse.length > 200 ? '${cleanResponse.substring(0, 200)}...' : cleanResponse}');

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
      debugPrint('💭 [Parse] Reasoning: ${reasoning.length > 100 ? '${reasoning.substring(0, 100)}...' : reasoning}');
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
      );

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Parse] Intent created successfully in ${duration.inMilliseconds}ms');
      debugPrint('🎯 [Parse] Final intent: ${intent.type.name} (${intent.confidence})');
      return intent;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('❌ [Parse] Failed to parse response after ${duration.inMilliseconds}ms: $e');
      debugPrint('📄 [Parse] Raw response that failed: ${response.length > 500 ? '${response.substring(0, 500)}...' : response}');
      throw Exception('Failed to parse classification response: $e');
    }
  }

  /// Create default intent when classification fails
  Intent _createDefaultIntent(String userMessage, String error, String requestId) {
    debugPrint('⚠️ [DefaultIntent] Creating fallback intent (ID: $requestId)');
    debugPrint('❌ [DefaultIntent] Error: $error');
    debugPrint('📝 [DefaultIntent] User message: ${userMessage.length > 100 ? '${userMessage.substring(0, 100)}...' : userMessage}');

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
