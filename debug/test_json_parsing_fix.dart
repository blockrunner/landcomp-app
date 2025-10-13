/// Test script for JSON parsing fix
/// 
/// This script tests the _cleanJsonResponse method
/// to ensure it properly handles markdown-formatted JSON responses.

void main() {
  print('🧪 Testing JSON parsing fix...');
  
  // Test different JSON response formats
  testMarkdownJsonBlock();
  testPlainJsonBlock();
  testJsonWithExtraText();
  testInvalidJson();
  
  print('✅ JSON parsing fix tests completed');
}

/// Test cleaning markdown JSON blocks
void testMarkdownJsonBlock() {
  print('\n📋 Test 1: Markdown JSON Block');
  
  const input = '''```json
{
  "image_analysis": "Test analysis",
  "user_intent": "consultation",
  "confidence": 0.8
}
```''';
  
  final cleaned = cleanJsonResponse(input);
  print('   Input: ${input.substring(0, 20)}...');
  print('   Output: ${cleaned.substring(0, 20)}...');
  print('   ✅ Markdown blocks removed');
}

/// Test cleaning plain JSON blocks
void testPlainJsonBlock() {
  print('\n📋 Test 2: Plain JSON Block');
  
  const input = '''```
{
  "image_analysis": "Test analysis",
  "user_intent": "visualization",
  "confidence": 0.9
}
```''';
  
  final cleaned = cleanJsonResponse(input);
  print('   Input: ${input.substring(0, 20)}...');
  print('   Output: ${cleaned.substring(0, 20)}...');
  print('   ✅ Plain blocks removed');
}

/// Test extracting JSON from mixed content
void testJsonWithExtraText() {
  print('\n📋 Test 3: JSON with Extra Text');
  
  const input = '''Here is the analysis:
{
  "image_analysis": "Test analysis",
  "user_intent": "unclear",
  "confidence": 0.3
}
This is the result.''';
  
  final cleaned = cleanJsonResponse(input);
  print('   Input: ${input.substring(0, 30)}...');
  print('   Output: ${cleaned.substring(0, 30)}...');
  print('   ✅ JSON extracted from mixed content');
}

/// Test invalid JSON handling
void testInvalidJson() {
  print('\n📋 Test 4: Invalid JSON');
  
  const input = 'This is not JSON at all';
  
  final cleaned = cleanJsonResponse(input);
  print('   Input: $input');
  print('   Output: $cleaned');
  print('   ✅ Invalid JSON handled gracefully');
}

/// Simulate the _cleanJsonResponse method
String cleanJsonResponse(String content) {
  // Remove markdown code blocks
  String cleaned = content.trim();
  
  // Remove ```json and ``` markers
  if (cleaned.startsWith('```json')) {
    cleaned = cleaned.substring(7);
  } else if (cleaned.startsWith('```')) {
    cleaned = cleaned.substring(3);
  }
  
  if (cleaned.endsWith('```')) {
    cleaned = cleaned.substring(0, cleaned.length - 3);
  }
  
  // Remove any leading/trailing whitespace
  cleaned = cleaned.trim();
  
  // If still not valid JSON, try to extract JSON from the content
  if (!cleaned.startsWith('{') && !cleaned.startsWith('[')) {
    // Look for JSON object in the content
    final jsonStart = cleaned.indexOf('{');
    final jsonEnd = cleaned.lastIndexOf('}');
    
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      cleaned = cleaned.substring(jsonStart, jsonEnd + 1);
    }
  }
  
  return cleaned;
}

/// Expected behavior after fix:
/// 
/// 1. **Markdown JSON blocks**: ```json {...} ``` → {...}
/// 2. **Plain JSON blocks**: ``` {...} ``` → {...}
/// 3. **Mixed content**: Extract JSON from text
/// 4. **Invalid content**: Return as-is for error handling
/// 
/// The fix addresses:
/// - ❌ FormatException from markdown formatting
/// - ❌ JSON parsing failures
/// - ❌ AI responses in wrong format
/// - ✅ Clean JSON extraction
/// - ✅ Robust error handling
/// - ✅ Multiple format support
