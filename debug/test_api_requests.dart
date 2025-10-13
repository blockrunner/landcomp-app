/// Тестовый скрипт для проверки API запросов к OpenAI и Google Gemini
/// 
/// Этот скрипт тестирует исправленные форматы запросов к API моделей
/// и проверяет работу прокси-сервера.
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print('🧪 Тестирование API запросов...\n');

  // Загружаем переменные окружения
  try {
    await dotenv.load();
    print('✅ Переменные окружения загружены');
  } catch (e) {
    print('❌ Ошибка загрузки .env: $e');
    return;
  }

  // Тестируем OpenAI API
  await testOpenAIAPI();
  
  // Тестируем Google Gemini API
  await testGeminiAPI();
  
  print('\n🎉 Тестирование завершено!');
}

/// Тестирование OpenAI API
Future<void> testOpenAIAPI() async {
  print('\n📡 Тестирование OpenAI API...');
  
  final apiKey = dotenv.env['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ OpenAI API ключ не найден');
    return;
  }

  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  try {
    final response = await dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
      data: {
        'model': 'gpt-4',
        'messages': [
          {'role': 'system', 'content': 'Ты полезный AI ассистент.'},
          {'role': 'user', 'content': 'Привет! Как дела?'},
        ],
        'max_tokens': 100,
        'temperature': 0.7,
        'stream': false,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
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
      print('📄 Ответ: ${response.data}');
    }
  } catch (e) {
    print('❌ Ошибка OpenAI API: $e');
  }
}

/// Тестирование Google Gemini API
Future<void> testGeminiAPI() async {
  print('\n📡 Тестирование Google Gemini API...');
  
  final apiKey = dotenv.env['GOOGLE_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Google API ключ не найден');
    return;
  }

  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  try {
    final response = await dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
      queryParameters: {
        'key': apiKey,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
      data: {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Привет! Как дела?'},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 100,
        },
      },
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
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
      print('📄 Ответ: ${response.data}');
    }
  } catch (e) {
    print('❌ Ошибка Google Gemini API: $e');
  }
}
