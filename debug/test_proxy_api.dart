/// Test script for proxy API functionality
/// 
/// This script tests the proxy server API endpoints to ensure
/// they are working correctly.
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing proxy API functionality...');
  
  // Test proxy status
  await testProxyStatus();
  
  // Test Gemini API through proxy
  await testGeminiProxy();
  
  print('✅ All tests completed!');
}

Future<void> testProxyStatus() async {
  print('\n📡 Testing proxy status...');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:3001/proxy/status'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      
      print('✅ Proxy status: ${data['status']}');
      print('✅ Main proxy: ${data['mainProxy']}');
      print('✅ Backup proxies: ${data['backupProxies']}');
    } else {
      print('❌ Proxy status check failed: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Error testing proxy status: $e');
  }
}

Future<void> testGeminiProxy() async {
  print('\n🤖 Testing Gemini API through proxy...');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://localhost:3001/proxy/gemini/v1beta/models/gemini-2.0-flash:generateContent?key=test')
    );
    
    request.headers.set('Content-Type', 'application/json');
    
    final requestBody = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': 'Hello, this is a test message.'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 100,
      }
    });
    
    request.write(requestBody);
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('✅ Gemini API test successful');
      print('📝 Response length: ${responseBody.length} characters');
    } else {
      print('❌ Gemini API test failed: ${response.statusCode}');
      final responseBody = await response.transform(utf8.decoder).join();
      print('📝 Error response: $responseBody');
    }
    
    client.close();
  } catch (e) {
    print('❌ Error testing Gemini API: $e');
  }
}