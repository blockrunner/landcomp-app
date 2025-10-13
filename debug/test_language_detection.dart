/// Test script for language detection functionality
/// 
/// This script tests that the AI can detect user language and respond appropriately.

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
  print('🧪 Testing Language Detection');
  print('=' * 50);
  
  // Test language detection logic
  testLanguageDetection();
  
  print('🏁 Test completed');
}

void testLanguageDetection() {
  print('🧪 Testing Language Detection Logic');
  print('-' * 30);
  
  // Test Russian text detection
  print('🔍 Testing Russian text detection:');
  final russianTexts = [
    'Привет, как дела?',
    'Какие розы лучше посадить?',
    'Hello, привет!', // Mixed
    'Розы и flowers', // Mixed
    'Hello world', // English
    '123456', // Numbers
  ];
  
  for (final text in russianTexts) {
    final isRussian = containsRussianText(text);
    print('   "${text}" -> ${isRussian ? "🇷🇺 Russian" : "🇺🇸 English"}');
  }
  print('');
  
  // Test conversation history language detection
  print('📚 Testing conversation history language detection:');
  
  final russianConversation = <Message>[
    Message.user(id: '1', content: 'Привет!'),
    Message.ai(id: '2', content: 'Hello!'),
    Message.user(id: '3', content: 'Какие растения посадить?'),
  ];
  
  final englishConversation = <Message>[
    Message.user(id: '1', content: 'Hello!'),
    Message.ai(id: '2', content: 'Hi there!'),
    Message.user(id: '3', content: 'What plants should I grow?'),
  ];
  
  final mixedConversation = <Message>[
    Message.user(id: '1', content: 'Hello!'),
    Message.ai(id: '2', content: 'Привет!'),
    Message.user(id: '3', content: 'Какие растения?'),
  ];
  
  print('   Russian conversation: ${detectUserLanguage("Test", russianConversation)}');
  print('   English conversation: ${detectUserLanguage("Test", englishConversation)}');
  print('   Mixed conversation: ${detectUserLanguage("Test", mixedConversation)}');
  print('');
  
  // Test system prompt enhancement
  print('🤖 Testing system prompt enhancement:');
  
  final basePrompt = '''You are an experienced gardener. Your expertise includes:
- Plant selection for different climate zones
- Garden and vegetable garden care
- Seasonal work and planning

Provide practical advice considering the Russian climate. Answer in English unless the user asks in Russian.''';
  
  final russianMessage = 'Какие розы лучше посадить?';
  final englishMessage = 'What roses should I plant?';
  
  final enhancedRussian = enhanceSystemPromptWithLanguage(basePrompt, russianMessage, russianConversation);
  final enhancedEnglish = enhanceSystemPromptWithLanguage(basePrompt, englishMessage, englishConversation);
  
  print('   Original prompt length: ${basePrompt.length} chars');
  print('   Enhanced for Russian: ${enhancedRussian.length} chars');
  print('   Enhanced for English: ${enhancedEnglish.length} chars');
  print('');
  
  print('   Russian enhancement includes: ${enhancedRussian.contains("ВАЖНО") ? "✅" : "❌"} Russian instruction');
  print('   English enhancement includes: ${enhancedEnglish.contains("IMPORTANT") ? "✅" : "❌"} English instruction');
  print('');
  
  // Test edge cases
  print('⚠️  Testing edge cases:');
  print('   Empty message: ${detectUserLanguage("", null)}');
  print('   Numbers only: ${detectUserLanguage("123456", null)}');
  print('   Special chars: ${detectUserLanguage("!@#\$%^&*()", null)}');
  print('   Mixed with numbers: ${detectUserLanguage("Привет123", null)}');
}

/// Check if text contains Russian characters
bool containsRussianText(String text) {
  // Russian Unicode range: \u0400-\u04FF
  return RegExp(r'[\u0400-\u04FF]').hasMatch(text);
}

/// Detect user language from message content
String detectUserLanguage(String message, List<Message>? conversationHistory) {
  // Check current message for Russian text
  if (containsRussianText(message)) {
    return 'ru';
  }
  
  // Check conversation history for Russian text
  if (conversationHistory != null) {
    for (final msg in conversationHistory) {
      if (msg.type == MessageType.user && containsRussianText(msg.content)) {
        return 'ru';
      }
    }
  }
  
  return 'en'; // Default to English
}

/// Enhance system prompt with language detection
String enhanceSystemPromptWithLanguage(
  String systemPrompt,
  String currentMessage,
  List<Message>? conversationHistory,
) {
  // Detect language from current message and conversation history
  final detectedLanguage = detectUserLanguage(currentMessage, conversationHistory);
  
  if (detectedLanguage == 'ru') {
    // Add Russian language instruction
    return '''$systemPrompt

ВАЖНО: Пользователь пишет на русском языке. Отвечай ТОЛЬКО на русском языке. Используй русские термины и учитывай российский климат и условия.''';
  } else {
    // Keep English as default
    return '''$systemPrompt

IMPORTANT: Respond in the same language as the user. If the user writes in Russian, respond in Russian. If in English, respond in English.''';
  }
}
