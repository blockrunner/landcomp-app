/// Intent Classifier for user request analysis
///
/// This classifier analyzes user requests and determines their intent
/// using OpenAI (primary) and Gemini (fallback) APIs.
library;

import 'dart:convert';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/shared/models/context.dart';

/// Intent classification service
class IntentClassifier {
  IntentClassifier._();

  static final IntentClassifier _instance = IntentClassifier._();
  static IntentClassifier get instance => _instance;

  final AIService _aiService = AIService.instance;

  /// Classify user intent from message and context
  Future<Intent> classifyIntent(
    String userMessage,
    RequestContext context,
  ) async {
    print(
      '🎯 Classifying intent for message: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...',
    );

    try {
      // Try OpenAI first
      return await _classifyWithOpenAI(userMessage, context);
    } catch (e) {
      print('⚠️ OpenAI classification failed: $e');
      print('🔄 Falling back to Gemini...');

      try {
        // Fallback to Gemini
        return await _classifyWithGemini(userMessage, context);
      } catch (e) {
        print('❌ Gemini classification also failed: $e');
        // Return default unclear intent
        return _createDefaultIntent(userMessage, e.toString());
      }
    }
  }

  /// Classify intent using OpenAI API
  Future<Intent> _classifyWithOpenAI(
    String userMessage,
    RequestContext context,
  ) async {
    final prompt = _buildClassificationPrompt(userMessage, context);

    print('🤖 Sending classification request to OpenAI...');

    final response = await _aiService.sendMessageWithSmartSelection(
      message: prompt,
      conversationHistory: [],
    );

    if (response.isSuccess && response.message != null) {
      return _parseClassificationResponse(response.message!);
    } else {
      throw Exception('OpenAI classification failed: ${response.message}');
    }
  }

  /// Classify intent using Gemini API
  Future<Intent> _classifyWithGemini(
    String userMessage,
    RequestContext context,
  ) async {
    final prompt = _buildClassificationPrompt(userMessage, context);

    print('🤖 Sending classification request to Gemini...');

    final response = await _aiService.sendMessageWithSmartSelection(
      message: prompt,
      conversationHistory: [],
    );

    if (response.isSuccess && response.message != null) {
      return _parseClassificationResponse(response.message!);
    } else {
      throw Exception('Gemini classification failed: ${response.message}');
    }
  }

  /// Build classification prompt
  String _buildClassificationPrompt(
    String userMessage,
    RequestContext context,
  ) {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are an intelligent intent classifier for a landscape design AI assistant. Analyze the user\'s message and conversation context to understand their true intent.',
    );
    buffer.writeln();

    buffer.writeln('Classify the user\'s intent into one of these types:');
    buffer.writeln(
      '- consultation: User is asking for advice, information, or guidance',
    );
    buffer.writeln(
      '- generation: User wants to create, modify, or generate new content (images, plans, designs)',
    );
    buffer.writeln(
      '- modification: User wants to change or update existing content',
    );
    buffer.writeln(
      '- analysis: User wants to analyze, examine, or understand something',
    );
    buffer.writeln('- unclear: Intent is ambiguous or unclear');
    buffer.writeln();

    buffer.writeln(
      'For consultation type, determine the most relevant subtype:',
    );
    buffer.writeln(
      '- landscapePlanning: Questions about planning, design, or transforming outdoor spaces',
    );
    buffer.writeln(
      '- plantSelection: Questions about plants, gardening, or plant care',
    );
    buffer.writeln(
      '- constructionAdvice: Questions about building, construction, or materials',
    );
    buffer.writeln(
      '- maintenanceAdvice: Questions about care, maintenance, or seasonal work',
    );
    buffer.writeln(
      '- generalQuestion: General questions not related to specific areas',
    );
    buffer.writeln();

    buffer.writeln('For generation type, determine the most relevant subtype:');
    buffer.writeln('- imageGeneration: User wants to create or modify images');
    buffer.writeln(
      '- planGeneration: User wants to create plans, diagrams, or layouts',
    );
    buffer.writeln('- textGeneration: User wants to generate text content');
    buffer.writeln();

    buffer.writeln(
      'CRITICAL: Focus on the user\'s INTENT, not just keywords. Consider:',
    );
    buffer.writeln('- What is the user trying to accomplish?');
    buffer.writeln(
      '- Do they want to CREATE something new or GET information?',
    );
    buffer.writeln(
      '- Are they asking "how to" or "what is" (consultation) vs "make this" or "change that" (generation)?',
    );
    buffer.writeln(
      '- Look at the conversation context - what came before this message?',
    );
    buffer.writeln();

    // Add image intent classification section
    buffer.writeln('Image Intent Classification:');
    buffer.writeln(
      'Analyze what the user wants to do with images based on context:',
    );
    buffer.writeln(
      '- analyzeNew: User uploaded NEW image(s) and wants to analyze or understand them',
    );
    buffer.writeln(
      '- analyzeRecent: User refers to recent images from conversation history',
    );
    buffer.writeln('- compareMultiple: User wants to compare several images');
    buffer.writeln(
      '- referenceSpecific: User references specific image (first, second, previous, last)',
    );
    buffer.writeln(
      '- generateBased: User wants to generate/create new content based on existing images',
    );
    buffer.writeln(
      '- noImageNeeded: Question doesn\'t require images to answer',
    );
    buffer.writeln('- unclear: Unclear if images are needed');
    buffer.writeln();

    buffer.writeln('Consider the conversation flow:');
    buffer.writeln(
      '- If user just uploaded an image and asks about it → analyzeNew',
    );
    buffer.writeln(
      '- If user asks about "this image" or "that design" → analyzeRecent',
    );
    buffer.writeln(
      '- If user wants to "change", "modify", or "create based on" → generateBased',
    );
    buffer.writeln(
      '- If user asks general questions without image context → noImageNeeded',
    );
    buffer.writeln();

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

    buffer.writeln('Current user message: "$userMessage"');
    buffer.writeln();

    // Add context information
    if (context.hasImages) {
      buffer.writeln('Context: User has uploaded images with current message');
      buffer.writeln(
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

    buffer.writeln();
    buffer.writeln('Return JSON response:');
    buffer.writeln('{');
    buffer.writeln(
      '  "type": "consultation|generation|modification|analysis|unclear",',
    );
    buffer.writeln(
      '  "subtype": "landscapePlanning|plantSelection|constructionAdvice|maintenanceAdvice|generalQuestion|imageGeneration|textGeneration|planGeneration|designModification|planAdjustment|contentUpdate|imageAnalysis|siteAnalysis|problemDiagnosis|ambiguous|incomplete",',
    );
    buffer.writeln('  "confidence": 0.0-1.0,');
    buffer.writeln('  "reasoning": "explanation of classification",');
    buffer.writeln('  "extracted_entities": ["entity1", "entity2"],');
    buffer.writeln(
      '  "imageIntent": "analyzeNew|analyzeRecent|compareMultiple|referenceSpecific|generateBased|noImageNeeded|unclear",',
    );
    buffer.writeln(
      '  "referencedImageIndices": [0, 1, 2],  // Only for referenceSpecific',
    );
    buffer.writeln('  "imagesNeeded": 0-5  // How many images needed');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Parse classification response from AI
  Intent _parseClassificationResponse(String response) {
    try {
      // Clean the response - remove any markdown formatting
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      print('📝 Parsing classification response: $cleanResponse');
      print('🔍 Raw response from AI: $response');

      final json = jsonDecode(cleanResponse) as Map<String, dynamic>;

      final type = IntentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IntentType.unclear,
      );

      final subtype = json['subtype'] != null
          ? IntentSubtype.values.firstWhere(
              (e) => e.name == json['subtype'],
              orElse: () => IntentSubtype.generalQuestion,
            )
          : null;

      final confidence = (json['confidence'] as num).toDouble().clamp(0.0, 1.0);
      final reasoning = json['reasoning'] as String? ?? 'No reasoning provided';
      final extractedEntities = List<String>.from(
        json['extracted_entities'] as List? ?? [],
      );

      // Parse image intent fields
      final imageIntent = json['imageIntent'] != null
          ? ImageIntent.values.firstWhere(
              (e) => e.name == json['imageIntent'],
              orElse: () => ImageIntent.unclear,
            )
          : null;

      final referencedImageIndices = json['referencedImageIndices'] != null
          ? List<int>.from(json['referencedImageIndices'] as List)
          : null;

      final imagesNeeded = json['imagesNeeded'] as int?;

      final metadata = <String, dynamic>{
        'classification_method': 'ai_classification',
        'raw_response': response,
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

      print(
        '✅ Intent classified: ${intent.type.name} (confidence: ${intent.confidence})',
      );
      if (intent.subtype != null) {
        print('   Subtype: ${intent.subtype!.name}');
      } else {
        print('   ⚠️ No subtype determined');
      }
      if (intent.imageIntent != null) {
        print('   Image Intent: ${intent.imageIntent!.name}');
        if (intent.imagesNeeded != null) {
          print('   Images Needed: ${intent.imagesNeeded}');
        }
        if (intent.referencedImageIndices != null &&
            intent.referencedImageIndices!.isNotEmpty) {
          print('   Referenced Indices: ${intent.referencedImageIndices}');
        }
      }
      return intent;
    } catch (e) {
      print('❌ Failed to parse classification response: $e');
      print('📝 Raw response: $response');
      throw Exception('Failed to parse classification response: $e');
    }
  }

  /// Create default intent when classification fails
  Intent _createDefaultIntent(String userMessage, String error) {
    print('⚠️ Creating default unclear intent due to classification failure');

    return Intent(
      type: IntentType.unclear,
      confidence: 0.1,
      reasoning: 'Classification failed: $error',
      metadata: {
        'classification_method': 'default_fallback',
        'error': error,
        'user_message': userMessage,
      },
      extractedEntities: [],
    );
  }

  /// Count total images in conversation history
  int _countImagesInHistory(List<Message> history) {
    int count = 0;
    for (final msg in history) {
      count += msg.attachments?.where((a) => a.isImage).length ?? 0;
    }
    return count;
  }

  /// Get classification statistics (for future use)
  Map<String, dynamic> getClassificationStats() {
    // TODO: Implement statistics tracking
    return {
      'total_classifications': 0,
      'openai_success_rate': 0.0,
      'gemini_success_rate': 0.0,
      'average_confidence': 0.0,
    };
  }
}
