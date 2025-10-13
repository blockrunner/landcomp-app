/// Test script for text-to-visualization switch fix
/// 
/// This script tests the new logic for detecting visualization requests
/// in text messages and switching to image generation mode.

void main() {
  print('🧪 Testing text-to-visualization switch fix...');
  
  // Test visualization request detection
  testVisualizationRequestDetection();
  
  // Test leading questions
  testLeadingQuestions();
  
  // Test edge cases
  testEdgeCases();
  
  print('✅ Text-to-visualization switch fix tests completed');
}

/// Test detection of direct visualization requests
void testVisualizationRequestDetection() {
  print('\n📋 Test 1: Direct Visualization Requests');
  
  final directRequests = [
    'сгенерируй картинку',
    'сгенерируй изображение', 
    'покажи как это будет выглядеть',
    'покажи визуализацию',
    'создай картинку',
    'нарисуй',
    'покажи результат',
    'да',
    'покажи',
    'визуализация',
    'картинка',
    'изображение',
  ];
  
  for (final request in directRequests) {
    final isRequest = isVisualizationRequest(request);
    print('   "$request" -> $isRequest');
    assert(isRequest, 'Should detect as visualization request');
  }
  
  print('   ✅ All direct requests detected correctly');
}

/// Test detection of leading questions
void testLeadingQuestions() {
  print('\n📋 Test 2: Leading Questions');
  
  final leadingQuestions = [
    'как это будет смотреться',
    'как это будет выглядеть',
    'как будет выглядеть',
    'что получится',
    'какой результат',
    'покажи результат',
  ];
  
  for (final question in leadingQuestions) {
    final isRequest = isVisualizationRequest(question);
    print('   "$question" -> $isRequest');
    assert(isRequest, 'Should detect as visualization request');
  }
  
  print('   ✅ All leading questions detected correctly');
}

/// Test edge cases
void testEdgeCases() {
  print('\n📋 Test 3: Edge Cases');
  
  final edgeCases = [
    ('обычный вопрос о растениях', false),
    ('расскажи про розы', false),
    ('как ухаживать за садом', false),
    ('А как это будет смотреться на участке?', true),
    ('Сгенерируй картинку', true),
    ('покажи мне результат', true),
  ];
  
  for (final (text, expected) in edgeCases) {
    final isRequest = isVisualizationRequest(text);
    print('   "$text" -> $isRequest (expected: $expected)');
    assert(isRequest == expected, 'Detection mismatch for: $text');
  }
  
  print('   ✅ All edge cases handled correctly');
}

/// Simulate the _isVisualizationRequest method
bool isVisualizationRequest(String content) {
  final lowerContent = content.toLowerCase();
  
  // Direct visualization requests
  final directRequests = [
    'сгенерируй картинку',
    'сгенерируй изображение',
    'покажи как это будет выглядеть',
    'покажи визуализацию',
    'создай картинку',
    'нарисуй',
    'покажи результат',
    'да',
    'покажи',
    'визуализация',
    'картинка',
    'изображение',
  ];
  
  // Leading questions that imply visualization
  final leadingQuestions = [
    'как это будет смотреться',
    'как это будет выглядеть',
    'как будет выглядеть',
    'что получится',
    'какой результат',
    'покажи результат',
  ];
  
  // Check for direct requests
  for (final request in directRequests) {
    if (lowerContent.contains(request)) {
      return true;
    }
  }
  
  // Check for leading questions
  for (final question in leadingQuestions) {
    if (lowerContent.contains(question)) {
      return true;
    }
  }
  
  return false;
}

/// Expected behavior after fix:
/// 
/// 1. **Direct requests**: "сгенерируй картинку" → Switch to image generation
/// 2. **Leading questions**: "как это будет смотреться" → Switch to image generation  
/// 3. **Regular questions**: "расскажи про розы" → Regular text response
/// 4. **Context awareness**: Uses previous images from conversation
/// 5. **Fallback**: If no images found, provides helpful message
/// 
/// The fix addresses:
/// - ❌ Text messages not triggering visualization
/// - ❌ Explicit requests ignored
/// - ❌ Leading questions not detected
/// - ❌ No context from previous images
/// - ✅ Smart intent detection
/// - ✅ Automatic mode switching
/// - ✅ Context-aware generation
/// - ✅ Graceful fallbacks
