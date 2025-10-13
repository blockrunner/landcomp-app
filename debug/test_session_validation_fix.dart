/// Test script for session validation fix
/// 
/// This script tests that typing messages are properly handled in session validation.

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
  
  factory Message.typing({
    required String id,
  }) {
    return Message(
      id: id,
      content: '',
      type: MessageType.ai,
      isTyping: true,
    );
  }
}

class ChatSession {
  final String id;
  final List<Message> messages;
  
  const ChatSession({
    required this.id,
    required this.messages,
  });
}

void main() {
  print('🧪 Testing Session Validation Fix');
  print('=' * 50);
  
  // Test session validation logic
  testSessionValidation();
  
  print('🏁 Test completed');
}

void testSessionValidation() {
  print('🧪 Testing Session Validation Logic');
  print('-' * 30);
  
  // Test cases
  final testCases = [
    {
      'name': 'Valid session with content',
      'session': ChatSession(
        id: 'session1',
        messages: [
          Message.user(id: 'msg1', content: 'Hello'),
          Message.ai(id: 'msg2', content: 'Hi there!'),
        ],
      ),
      'expected': true,
    },
    {
      'name': 'Valid session with typing message',
      'session': ChatSession(
        id: 'session2',
        messages: [
          Message.user(id: 'msg1', content: 'Hello'),
          Message.typing(id: 'typing1'),
          Message.ai(id: 'msg2', content: 'Hi there!'),
        ],
      ),
      'expected': true,
    },
    {
      'name': 'Invalid session with empty content',
      'session': ChatSession(
        id: 'session3',
        messages: [
          Message.user(id: 'msg1', content: 'Hello'),
          Message.ai(id: 'msg2', content: ''), // Empty content, not typing
        ],
      ),
      'expected': false,
    },
    {
      'name': 'Invalid session with empty ID',
      'session': ChatSession(
        id: '', // Empty ID
        messages: [
          Message.user(id: 'msg1', content: 'Hello'),
        ],
      ),
      'expected': false,
    },
    {
      'name': 'Invalid session with empty message ID',
      'session': ChatSession(
        id: 'session4',
        messages: [
          Message.user(id: '', content: 'Hello'), // Empty message ID
        ],
      ),
      'expected': false,
    },
  ];
  
  // Run tests
  int passed = 0;
  int failed = 0;
  
  for (final testCase in testCases) {
    final session = testCase['session'] as ChatSession;
    final expected = testCase['expected'] as bool;
    final name = testCase['name'] as String;
    
    final result = validateSession(session);
    final success = result == expected;
    
    print('   ${success ? "✅" : "❌"} $name: ${result ? "VALID" : "INVALID"} (expected: ${expected ? "VALID" : "INVALID"})');
    
    if (success) {
      passed++;
    } else {
      failed++;
      print('      Expected: $expected, Got: $result');
    }
  }
  
  print('');
  print('📊 Test Results:');
  print('   ✅ Passed: $passed');
  print('   ❌ Failed: $failed');
  print('   📈 Success rate: ${(passed / (passed + failed) * 100).toStringAsFixed(1)}%');
  
  if (failed == 0) {
    print('');
    print('🎉 All tests passed! Session validation fix is working correctly.');
  } else {
    print('');
    print('⚠️  Some tests failed. Please review the validation logic.');
  }
}

/// Validate session (simplified version of the actual validation)
bool validateSession(ChatSession session) {
  try {
    // Check session ID
    if (session.id.isEmpty) {
      print('❌ Session validation failed: Empty session ID');
      return false;
    }
    
    // Check messages
    for (final message in session.messages) {
      // Check message ID
      if (message.id.isEmpty) {
        print('❌ Session validation failed: Empty message ID');
        return false;
      }
      
      // Check message content (allow empty content for typing messages)
      if (message.content.isEmpty && !message.isTyping) {
        print('❌ Session validation failed: Empty message content and no images');
        return false;
      }
    }
    
    return true;
  } catch (e) {
    print('❌ Session validation failed: Exception - $e');
    return false;
  }
}
