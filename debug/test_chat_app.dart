/// Тест чата в приложении
/// 
/// Этот скрипт тестирует работу чата через AIService
library;

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Импортируем необходимые классы
import 'package:landcomp_app/core/config/env_config.dart';
import 'package:landcomp_app/core/network/ai_service.dart';

void main() async {
  print('🧪 Тестирование чата в приложении...\n');

  // Загружаем переменные окружения
  try {
    await dotenv.load();
    print('✅ Переменные окружения загружены');
  } catch (e) {
    print('❌ Ошибка загрузки .env: $e');
    return;
  }

  // Проверяем конфигурацию
  print('\n📋 Проверка конфигурации:');
  print('   OpenAI настроен: ${EnvConfig.isOpenAIConfigured ? '✅' : '❌'}');
  print('   Google настроен: ${EnvConfig.isGoogleConfigured ? '✅' : '❌'}');
  print('   Прокси настроен: ${EnvConfig.isProxyConfigured ? '✅' : '❌'}');

  if (!EnvConfig.isOpenAIConfigured && !EnvConfig.isGoogleConfigured) {
    print('❌ Ни один AI сервис не настроен');
    return;
  }

  // Инициализируем AIService
  try {
    await AIService.instance.initialize();
    print('✅ AIService инициализирован');
  } catch (e) {
    print('❌ Ошибка инициализации AIService: $e');
    return;
  }

  // Тестируем OpenAI
  if (EnvConfig.isOpenAIConfigured) {
    print('\n📡 Тестирование OpenAI...');
    try {
      final response = await AIService.instance.sendToOpenAI(
        message: 'Привет! Как дела?',
        systemPrompt: 'Ты полезный AI ассистент.',
      );
      print('✅ OpenAI работает!');
      print('📝 Ответ: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');
    } catch (e) {
      print('❌ Ошибка OpenAI: $e');
    }
  }

  // Тестируем Google Gemini
  if (EnvConfig.isGoogleConfigured) {
    print('\n📡 Тестирование Google Gemini...');
    try {
      final response = await AIService.instance.sendToGemini(
        message: 'Привет! Как дела?',
        systemPrompt: 'Ты полезный AI ассистент.',
      );
      print('✅ Google Gemini работает!');
      print('📝 Ответ: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');
    } catch (e) {
      print('❌ Ошибка Google Gemini: $e');
    }
  }

  // Тестируем общий метод
  print('\n📡 Тестирование общего метода...');
  try {
    final response = await AIService.instance.sendMessage(
      message: 'Привет! Как дела?',
      systemPrompt: 'Ты полезный AI ассистент.',
    );
    print('✅ Общий метод работает!');
    print('📝 Ответ: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');
  } catch (e) {
    print('❌ Ошибка общего метода: $e');
  }

  print('\n🎉 Тестирование завершено!');
}
