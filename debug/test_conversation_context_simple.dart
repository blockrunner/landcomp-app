/// Simple test script for conversation context functionality
/// 
/// This script tests the conversation history building logic without Flutter dependencies.

import 'dart:io';

// Mock classes for testing
class MessageType {
  static const user = MessageType._('user');
  static const ai = MessageType._('ai');
  static const system = MessageType._('system');
  
  const MessageType._(this.name);
  final String name;
}

class Message {
  final String id;
  final String content;
  final MessageType type;
  final bool isTyping;
  final bool isError;
  
  const Message({
    required this.id,
    required this.content,
    required this.type,
    this.isTyping = false,
    this.isError = false,
  });
  
  factory Message.user({
    required String id,
    required String content,
  }) {
    return Message(
      id: id,
      content: content,
      type: MessageType.user,
    );
  }
  
  factory Message.ai({
    required String id,
    required String content,
  }) {
    return Message(
      id: id,
      content: content,
      type: MessageType.ai,
    );
  }
}

void main() {
  print('🧪 Testing Conversation Context Logic');
  print('=' * 50);
  
  // Test conversation history building
  testConversationHistoryBuilding();
  
  print('🏁 Test completed');
}

void testConversationHistoryBuilding() {
  print('🧪 Testing Conversation History Building');
  print('-' * 30);
  
  // Create a conversation history
  final conversationHistory = <Message>[
    Message.user(
      id: 'msg1',
      content: 'Какие розы лучше посадить в Подмосковье?',
    ),
    Message.ai(
      id: 'msg2',
      content: 'Для Подмосковья рекомендую морозостойкие сорта роз: Глория Дей, Черная Магия, Фламинго.',
    ),
    Message.user(
      id: 'msg3',
      content: 'А когда их лучше сажать?',
    ),
    Message.ai(
      id: 'msg4',
      content: 'Розы лучше сажать весной или осенью, когда почва прогреется.',
    ),
  ];
  
  print('📚 Original conversation history:');
  for (int i = 0; i < conversationHistory.length; i++) {
    final msg = conversationHistory[i];
    print('  ${i + 1}. ${msg.type.name}: ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
  }
  print('');
  
  // Test filtering logic (simulate what happens in the AI service)
  final filteredHistory = conversationHistory
      .where((m) => !m.isTyping && !m.isError)
      .toList();
  
  print('🔍 Filtered history (removing typing/error messages):');
  for (int i = 0; i < filteredHistory.length; i++) {
    final msg = filteredHistory[i];
    print('  ${i + 1}. ${msg.type.name}: ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
  }
  print('');
  
  // Test taking last N messages
  final maxHistoryMessages = 3;
  final relevantHistory = filteredHistory
      .reversed
      .take(maxHistoryMessages)
      .toList()
      .reversed;
  
  print('📝 Last $maxHistoryMessages messages for AI context:');
  final relevantHistoryList = relevantHistory.toList();
  for (int i = 0; i < relevantHistoryList.length; i++) {
    final msg = relevantHistoryList[i];
    print('  ${i + 1}. ${msg.type.name}: ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
  }
  print('');
  
  // Test OpenAI message format
  print('🤖 OpenAI message format:');
  final openAIMessages = <Map<String, dynamic>>[
    {'role': 'system', 'content': 'You are a helpful gardening assistant.'},
  ];
  
  for (final msg in relevantHistoryList) {
    openAIMessages.add({
      'role': msg.type == MessageType.user ? 'user' : 'assistant',
      'content': msg.content,
    });
  }
  
  for (int i = 0; i < openAIMessages.length; i++) {
    final msg = openAIMessages[i];
    final content = msg['content'] as String;
    print('  ${i + 1}. ${msg['role']}: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
  }
  print('');
  
  // Test Gemini message format
  print('🔮 Gemini message format:');
  final geminiContents = <Map<String, dynamic>>[];
  
  for (final msg in relevantHistoryList) {
    geminiContents.add({
      'role': msg.type == MessageType.user ? 'user' : 'model',
      'parts': [{'text': msg.content}],
    });
  }
  
  for (int i = 0; i < geminiContents.length; i++) {
    final content = geminiContents[i];
    final text = (content['parts'] as List)[0]['text'] as String;
    print('  ${i + 1}. ${content['role']}: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
  }
  print('');
  
  // Verify context preservation
  print('✅ Context Verification:');
  final lastUserMessage = relevantHistoryList.lastWhere((m) => m.type == MessageType.user);
  final lastAIMessage = relevantHistoryList.lastWhere((m) => m.type == MessageType.ai);
  
  print('   Last user message: "${lastUserMessage.content}"');
  print('   Last AI message: "${lastAIMessage.content}"');
  
  // Check if the conversation flow makes sense
  if (lastUserMessage.content.contains('сажать') && lastAIMessage.content.contains('сажать')) {
    print('   ✅ Context preserved: AI remembers the planting discussion');
  } else {
    print('   ❌ Context may be lost: AI response doesn\'t match user question');
  }
  
  print('');
}
