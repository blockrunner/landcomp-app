/// Тестовый скрипт для проверки сетевого соединения
/// 
/// Этот скрипт тестирует подключение к API без использования AIService
/// для диагностики проблем с сетью и прокси.
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Тестовый класс для проверки сетевого соединения
class NetworkConnectionTester {
  static Future<void> runAllTests() async {
    print('🌐 Запуск тестов сетевого соединения...\n');
    
    try {
      // Тест 1: Проверка базового HTTP соединения
      await _testBasicHttpConnection();
      
      // Тест 2: Проверка соединения через прокси
      await _testProxyConnection();
      
      // Тест 3: Проверка OpenAI API напрямую
      await _testOpenAIDirect();
      
      // Тест 4: Проверка Google Gemini API напрямую
      await _testGoogleGeminiDirect();
      
      // Тест 5: Проверка таймаутов
      await _testTimeouts();
      
      print('\n✅ Все тесты сетевого соединения завершены!');
      
    } catch (e) {
      print('\n❌ Ошибка во время тестирования сети: $e');
    }
  }
  
  /// Тест 1: Проверка базового HTTP соединения
  static Future<void> _testBasicHttpConnection() async {
    print('🔗 Тест 1: Проверка базового HTTP соединения...');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    try {
      final response = await dio.get('https://httpbin.org/get');
      print('   ✅ Базовое HTTP соединение работает: ${response.statusCode}\n');
    } catch (e) {
      print('   ❌ Ошибка базового HTTP соединения: $e\n');
    }
  }
  
  /// Тест 2: Проверка соединения через прокси
  static Future<void> _testProxyConnection() async {
    print('🔒 Тест 2: Проверка соединения через прокси...');
    
    final proxyUrl = Platform.environment['ALL_PROXY'] ?? '';
    if (proxyUrl.isEmpty) {
      print('   ⚠️ Прокси не настроен, пропускаем тест\n');
      return;
    }
    
    print('   📡 Используем прокси: $proxyUrl');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    
    try {
      // Настройка прокси
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        final proxyUri = Uri.parse(proxyUrl);
        
        client.findProxy = (uri) {
          return 'PROXY ${proxyUri.host}:${proxyUri.port}';
        };
        
        // Аутентификация прокси
        if (proxyUri.userInfo.isNotEmpty) {
          final credentials = proxyUri.userInfo.split(':');
          if (credentials.length == 2) {
            client.authenticate = (uri, scheme, realm) async {
              client.addCredentials(uri, scheme, 
                HttpClientBasicCredentials(credentials[0], credentials[1]));
              return true;
            };
          }
        }
        
        return client;
      };
      
      final response = await dio.get('https://httpbin.org/get');
      print('   ✅ Соединение через прокси работает: ${response.statusCode}\n');
    } catch (e) {
      print('   ❌ Ошибка соединения через прокси: $e\n');
    }
  }
  
  /// Тест 3: Проверка OpenAI API напрямую
  static Future<void> _testOpenAIDirect() async {
    print('🤖 Тест 3: Проверка OpenAI API напрямую...');
    
    final apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('   ⚠️ OpenAI API ключ не настроен, пропускаем тест\n');
      return;
    }
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    
    try {
      final response = await dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'Привет! Это тест.'},
          ],
          'max_tokens': 50,
        },
      );
      
      if (response.statusCode == 200) {
        print('   ✅ OpenAI API работает: ${response.statusCode}\n');
      } else {
        print('   ⚠️ OpenAI API ответил: ${response.statusCode}\n');
      }
    } catch (e) {
      print('   ❌ Ошибка OpenAI API: $e\n');
    }
  }
  
  /// Тест 4: Проверка Google Gemini API напрямую
  static Future<void> _testGoogleGeminiDirect() async {
    print('🔍 Тест 4: Проверка Google Gemini API напрямую...');
    
    final apiKey = Platform.environment['GOOGLE_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('   ⚠️ Google API ключ не настроен, пропускаем тест\n');
      return;
    }
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    
    try {
      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
        queryParameters: {'key': apiKey},
        data: {
          'contents': [
            {
              'parts': [
                {'text': 'Привет! Это тест.'},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 50,
          },
        },
      );
      
      if (response.statusCode == 200) {
        print('   ✅ Google Gemini API работает: ${response.statusCode}\n');
      } else {
        print('   ⚠️ Google Gemini API ответил: ${response.statusCode}\n');
      }
    } catch (e) {
      print('   ❌ Ошибка Google Gemini API: $e\n');
    }
  }
  
  /// Тест 5: Проверка таймаутов
  static Future<void> _testTimeouts() async {
    print('⏱️ Тест 5: Проверка таймаутов...');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    
    try {
      final stopwatch = Stopwatch()..start();
      await dio.get('https://httpbin.org/delay/2');
      stopwatch.stop();
      
      print('   ✅ Таймауты работают корректно: ${stopwatch.elapsedMilliseconds}ms\n');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        print('   ✅ Таймауты работают корректно (ожидаемая ошибка)\n');
      } else {
        print('   ❌ Неожиданная ошибка таймаута: $e\n');
      }
    }
  }
}

/// Запуск тестов
void main() async {
  await NetworkConnectionTester.runAllTests();
}
