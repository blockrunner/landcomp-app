/// Простой тест API без Flutter зависимостей
/// 
/// Этот скрипт тестирует API запросы напрямую через HTTP
library;

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 Простое тестирование API запросов...\n');

  // Читаем .env файл
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ Файл .env не найден');
    return;
  }

  final envContent = await envFile.readAsString();
  final envVars = <String, String>{};
  
  for (final line in envContent.split('\n')) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim().replaceAll('"', '');
      envVars[key] = value;
    }
  }

  print('✅ Переменные окружения загружены');
  print('   OpenAI ключ: ${envVars['OPENAI_API_KEY']?.substring(0, 10)}...');
  print('   Google ключ: ${envVars['GOOGLE_API_KEY']?.substring(0, 10)}...');
  print('   Прокси: ${envVars['ALL_PROXY']?.substring(0, 20)}...\n');

  // Тестируем OpenAI API
  await testOpenAIAPI(envVars);
  
  // Тестируем Google Gemini API
  await testGeminiAPI(envVars);
  
  print('\n🎉 Тестирование завершено!');
}

/// Тестирование OpenAI API
Future<void> testOpenAIAPI(Map<String, String> envVars) async {
  print('📡 Тестирование OpenAI API...');
  
  final apiKey = envVars['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ OpenAI API ключ не найден');
    return;
  }

  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('https://api.openai.com/v1/chat/completions')
    );
    
    request.headers.set('Authorization', 'Bearer $apiKey');
    request.headers.set('Content-Type', 'application/json');
    
    final requestBody = {
      'model': 'gpt-4',
      'messages': [
        {'role': 'system', 'content': 'Ты полезный AI ассистент.'},
        {'role': 'user', 'content': 'Привет! Как дела?'},
      ],
      'max_tokens': 100,
      'temperature': 0.7,
      'stream': false,
    };
    
    request.write(utf8.encode(jsonEncode(requestBody)));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final messageObj = choices[0]['message'] as Map<String, dynamic>;
        final content = messageObj['content'] as String?;
        print('✅ OpenAI API работает!');
        print('📝 Ответ: ${content?.substring(0, content.length > 100 ? 100 : content.length)}...');
      } else {
        print('❌ Пустой ответ от OpenAI');
      }
    } else {
      print('❌ OpenAI API ошибка: ${response.statusCode}');
      final responseBody = await response.transform(utf8.decoder).join();
      print('📄 Ответ: $responseBody');
    }
  } catch (e) {
    print('❌ Ошибка OpenAI API: $e');
  } finally {
    client.close();
  }
}

/// Тестирование Google Gemini API
Future<void> testGeminiAPI(Map<String, String> envVars) async {
  print('\n📡 Тестирование Google Gemini API...');
  
  final apiKey = envVars['GOOGLE_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Google API ключ не найден');
    return;
  }

  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey')
    );
    
    request.headers.set('Content-Type', 'application/json');
    
    final requestBody = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': 'Привет! Как дела?'},
          ],
        },
      ],
    };
    
    final jsonBody = jsonEncode(requestBody);
    print('📤 Отправляем JSON: $jsonBody');
    request.write(utf8.encode(jsonBody));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>;
      if (candidates.isNotEmpty) {
        final candidate = candidates[0] as Map<String, dynamic>;
        final content = candidate['content'] as Map<String, dynamic>?;
        if (content != null) {
          final parts = content['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            print('✅ Google Gemini API работает!');
            print('📝 Ответ: ${text?.substring(0, text.length > 100 ? 100 : text.length)}...');
          } else {
            print('❌ Пустые части в ответе Gemini');
          }
        } else {
          print('❌ Пустой контент в ответе Gemini');
        }
      } else {
        print('❌ Пустые кандидаты в ответе Gemini');
      }
    } else {
      print('❌ Google Gemini API ошибка: ${response.statusCode}');
      final responseBody = await response.transform(utf8.decoder).join();
      print('📄 Ответ: $responseBody');
    }
  } catch (e) {
    print('❌ Ошибка Google Gemini API: $e');
  } finally {
    client.close();
  }
}
