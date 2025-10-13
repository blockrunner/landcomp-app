/// Финальный тест приложения
/// 
/// Этот скрипт проверяет основные компоненты приложения
library;

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 Финальное тестирование приложения...\n');

  // Проверяем, что Flutter приложение запущено
  print('📱 Проверка Flutter приложения...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:8083'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ Flutter приложение работает на порту 8083');
    } else {
      print('❌ Flutter приложение недоступно: ${response.statusCode}');
    }
    client.close();
  } catch (e) {
    print('❌ Ошибка подключения к Flutter приложению: $e');
  }

  // Проверяем прокси-сервер
  print('\n📡 Проверка прокси-сервера...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:3001/proxy/status'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      print('✅ Прокси-сервер работает');
      print('   Статус: ${data['status']}');
      print('   Прокси: ${data['mainProxy']?.toString().substring(0, 20)}...');
    } else {
      print('❌ Прокси-сервер недоступен: ${response.statusCode}');
    }
    client.close();
  } catch (e) {
    print('❌ Ошибка подключения к прокси-серверу: $e');
  }

  // Проверяем .env файл
  print('\n📄 Проверка .env файла...');
  final envFile = File('.env');
  if (await envFile.exists()) {
    final envContent = await envFile.readAsString();
    final lines = envContent.split('\n').where((line) => 
      line.trim().isNotEmpty && !line.startsWith('#')).toList();
    
    print('✅ .env файл найден');
    print('   Переменных: ${lines.length}');
    
    // Проверяем ключевые переменные
    final hasOpenAI = envContent.contains('OPENAI_API_KEY=');
    final hasGoogle = envContent.contains('GOOGLE_API_KEY=');
    final hasProxy = envContent.contains('ALL_PROXY=');
    
    print('   OpenAI ключ: ${hasOpenAI ? '✅' : '❌'}');
    print('   Google ключ: ${hasGoogle ? '✅' : '❌'}');
    print('   Прокси: ${hasProxy ? '✅' : '❌'}');
  } else {
    print('❌ .env файл не найден');
  }

  // Проверяем основные файлы приложения
  print('\n📁 Проверка файлов приложения...');
  final files = [
    'lib/core/network/ai_service.dart',
    'lib/core/config/env_config.dart',
    'lib/app/app.dart',
    'pubspec.yaml',
  ];
  
  for (final file in files) {
    final fileObj = File(file);
    if (await fileObj.exists()) {
      print('✅ $file');
    } else {
      print('❌ $file');
    }
  }

  print('\n🎉 Финальное тестирование завершено!');
  print('\n📋 Инструкции для тестирования:');
  print('1. Откройте браузер и перейдите на http://localhost:8083');
  print('2. Убедитесь, что прокси-сервер запущен: cd debug && node proxy-server.js');
  print('3. Попробуйте отправить сообщение в чат');
  print('4. Проверьте консоль браузера на наличие ошибок');
}
