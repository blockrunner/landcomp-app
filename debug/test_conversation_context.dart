/// Test script for conversation context functionality
/// 
/// This script tests that the AI can remember previous messages in a conversation
/// by asking follow-up questions that require context.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/core/config/env_config.dart';

void main() async {
  print('🧪 Testing Conversation Context Functionality');
  print('=' * 50);
  
  // Initialize environment
  await EnvConfig.initialize();
  
  // Initialize AI service
  final aiService = AIService.instance;
  await aiService.initialize();
  
  print('✅ AI Service initialized');
  print('📊 Service status: ${aiService.getStatus()}');
  print('');
  
  // Test conversation context
  await testConversationContext(aiService);
}

Future<void> testConversationContext(AIService aiService) async {
  print('🧪 Testing Conversation Context');
  print('-' * 30);
  
  // Create a conversation history
  final conversationHistory = <Message>[
    Message.user(
      id: 'msg1',
      content: 'Какие розы лучше посадить в Подмосковье?',
    ),
    Message.ai(
      id: 'msg2',
      content: 'Для Подмосковья рекомендую морозостойкие сорта роз: Глория Дей, Черная Магия, Фламинго. Они хорошо переносят зиму и цветут обильно.',
      agentId: 'gardener',
    ),
  ];
  
  print('📚 Conversation history:');
  for (int i = 0; i < conversationHistory.length; i++) {
    final msg = conversationHistory[i];
    print('  ${i + 1}. ${msg.type.name}: ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
  }
  print('');
  
  // Test follow-up question that requires context
  final followUpQuestion = 'А когда их лучше сажать?';
  print('❓ Follow-up question: $followUpQuestion');
  print('   (This should be understood as asking about planting roses)');
  print('');
  
  try {
    // Test with conversation history
    print('🔄 Testing WITH conversation history...');
    final responseWithHistory = await aiService.sendMessageWithSmartSelection(
      message: followUpQuestion,
      conversationHistory: conversationHistory,
    );
    
    if (responseWithHistory.isSuccess) {
      print('✅ Response WITH history:');
      print('   ${responseWithHistory.message}');
      print('   Agent: ${responseWithHistory.agent?.name}');
      print('   Confidence: ${responseWithHistory.confidence}');
    } else {
      print('❌ Error with history: ${responseWithHistory.message}');
    }
    print('');
    
    // Test without conversation history (for comparison)
    print('🔄 Testing WITHOUT conversation history...');
    final responseWithoutHistory = await aiService.sendMessageWithSmartSelection(
      message: followUpQuestion,
    );
    
    if (responseWithoutHistory.isSuccess) {
      print('⚠️  Response WITHOUT history:');
      print('   ${responseWithoutHistory.message}');
      print('   Agent: ${responseWithoutHistory.agent?.name}');
      print('   Confidence: ${responseWithoutHistory.confidence}');
    } else {
      print('❌ Error without history: ${responseWithoutHistory.message}');
    }
    print('');
    
    // Analyze results
    print('📊 Analysis:');
    if (responseWithHistory.isSuccess && responseWithoutHistory.isSuccess) {
      final withHistory = responseWithHistory.message!.toLowerCase();
      final withoutHistory = responseWithoutHistory.message!.toLowerCase();
      
      // Check if the response with history mentions roses or planting
      final mentionsRoses = withHistory.contains('роза') || withHistory.contains('rose');
      final mentionsPlanting = withHistory.contains('посад') || withHistory.contains('plant');
      
      if (mentionsRoses || mentionsPlanting) {
        print('✅ SUCCESS: AI remembered the context about roses!');
        print('   Response with history is more specific and contextual');
      } else {
        print('⚠️  PARTIAL: AI response may not be using context effectively');
      }
      
      print('   With history: ${withHistory.length} chars');
      print('   Without history: ${withoutHistory.length} chars');
    } else {
      print('❌ FAILED: Could not get responses from AI service');
    }
    
  } catch (e) {
    print('❌ Error during test: $e');
  }
  
  print('');
  print('🏁 Test completed');
}

/// Helper function to check if response is contextual
bool isContextualResponse(String response, List<String> contextKeywords) {
  final lowerResponse = response.toLowerCase();
  return contextKeywords.any((keyword) => lowerResponse.contains(keyword.toLowerCase()));
}
