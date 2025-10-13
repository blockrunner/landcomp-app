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
    print('🎯 Classifying intent for message: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...');

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
  String _buildClassificationPrompt(String userMessage, RequestContext context) {
    final buffer = StringBuffer();
    
    buffer.writeln('Analyze the user\'s intent and classify it into one of these types:');
    buffer.writeln('- consultation: User asking question/advice');
    buffer.writeln('- generation: User wants image generated');
    buffer.writeln('- modification: User wants to modify existing');
    buffer.writeln('- analysis: User wants analysis of situation/image');
    buffer.writeln('- unclear: Intent is unclear');
    buffer.writeln();
    
    buffer.writeln('For consultation type, also determine the subtype:');
    buffer.writeln('- landscapePlanning: Planning, design, transformation of plots/landscapes');
    buffer.writeln('- plantSelection: Plant care, gardening, plant selection');
    buffer.writeln('- constructionAdvice: Building, construction, materials');
    buffer.writeln('- maintenanceAdvice: Care, maintenance, seasonal work');
    buffer.writeln('- generalQuestion: General questions not related to specific areas');
    buffer.writeln();
    
    buffer.writeln('Key words for landscape planning: участок, преобразовать, дизайн, планировка, зонирование, ландшафт, территория, площадь, размещение, организация');
    buffer.writeln('Key words for plant selection: растение, цветок, дерево, сад, огород, посадка, уход, полив, удобрение, обрезка, сезон');
    buffer.writeln();
    
    // Add recent conversation history for context
    if (context.conversationHistory.isNotEmpty) {
      buffer.writeln('Recent conversation context:');
      final recentMessages = context.conversationHistory.length > 3 
          ? context.conversationHistory.sublist(context.conversationHistory.length - 3)
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
    }
    
    if (context.hasRecentImages) {
      buffer.writeln('Context: Recent conversation includes images');
    }
    
    if (context.conversationLength > 0) {
      buffer.writeln('Context: Conversation has ${context.conversationLength} messages');
    }
    
    if (context.userLanguage != null) {
      buffer.writeln('Context: User language detected as ${context.userLanguage}');
    }
    
    buffer.writeln();
    buffer.writeln('Return JSON response:');
    buffer.writeln('{');
    buffer.writeln('  "type": "consultation|generation|modification|analysis|unclear",');
    buffer.writeln('  "subtype": "landscapePlanning|plantSelection|constructionAdvice|maintenanceAdvice|generalQuestion|imageGeneration|textGeneration|planGeneration|designModification|planAdjustment|contentUpdate|imageAnalysis|siteAnalysis|problemDiagnosis|ambiguous|incomplete",');
    buffer.writeln('  "confidence": 0.0-1.0,');
    buffer.writeln('  "reasoning": "explanation of classification",');
    buffer.writeln('  "extracted_entities": ["entity1", "entity2"]');
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
      final extractedEntities = List<String>.from(json['extracted_entities'] as List? ?? []);
      
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
      );

      print('✅ Intent classified: ${intent.type.name} (confidence: ${intent.confidence})');
      if (intent.subtype != null) {
        print('   Subtype: ${intent.subtype!.name}');
      } else {
        print('   ⚠️ No subtype determined');
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
