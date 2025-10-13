/// Тестовый скрипт для проверки конфигурации окружения
/// 
/// Этот скрипт проверяет правильность загрузки переменных окружения
/// и их валидность.
library;

import 'dart:io';
import 'package:landcomp_app/core/config/env_config.dart';

/// Тестовый класс для проверки конфигурации окружения
class EnvConfigTester {
  static Future<void> runAllTests() async {
    print('⚙️ Запуск тестов конфигурации окружения...\n');
    
    try {
      // Тест 1: Проверка загрузки переменных окружения
      await _testEnvironmentVariables();
      
      // Тест 2: Проверка API ключей
      await _testApiKeys();
      
      // Тест 3: Проверка прокси конфигурации
      await _testProxyConfiguration();
      
      // Тест 4: Проверка валидации конфигурации
      await _testConfigurationValidation();
      
      // Тест 5: Проверка методов получения конфигурации
      await _testConfigurationMethods();
      
      print('\n✅ Все тесты конфигурации завершены!');
      
    } catch (e) {
      print('\n❌ Ошибка во время тестирования конфигурации: $e');
    }
  }
  
  /// Тест 1: Проверка загрузки переменных окружения
  static Future<void> _testEnvironmentVariables() async {
    print('📋 Тест 1: Проверка загрузки переменных окружения...');
    
    final envVars = [
      'OPENAI_API_KEY',
      'GOOGLE_API_KEY',
      'GOOGLE_API_KEYS_FALLBACK',
      'ALL_PROXY',
      'BACKUP_PROXIES',
      'YC_API_KEY_ID',
      'YC_API_KEY',
      'YC_FOLDER_ID',
      'STABILITY_API_KEY',
      'HUGGINGFACE_API_KEY',
    ];
    
    for (final varName in envVars) {
      final value = Platform.environment[varName] ?? '';
      if (value.isNotEmpty) {
        print('   ✅ $varName: ${value.length > 20 ? '${value.substring(0, 20)}...' : value}');
      } else {
        print('   ⚠️ $varName: не установлен');
      }
    }
    print('');
  }
  
  /// Тест 2: Проверка API ключей
  static Future<void> _testApiKeys() async {
    print('🔑 Тест 2: Проверка API ключей...');
    
    // OpenAI API Key
    final openaiKey = EnvConfig.openaiApiKey;
    if (openaiKey.isNotEmpty) {
      print('   ✅ OpenAI API Key: ${openaiKey.startsWith('sk-') ? 'корректный формат' : 'некорректный формат'}');
    } else {
      print('   ❌ OpenAI API Key: не установлен');
    }
    
    // Google API Key
    final googleKey = EnvConfig.googleApiKey;
    if (googleKey.isNotEmpty) {
      print('   ✅ Google API Key: ${googleKey.startsWith('AIza') ? 'корректный формат' : 'некорректный формат'}');
    } else {
      print('   ❌ Google API Key: не установлен');
    }
    
    // Fallback Google Keys
    final fallbackKeys = EnvConfig.googleApiKeysFallback;
    print('   📊 Резервных Google ключей: ${fallbackKeys.length}');
    for (var i = 0; i < fallbackKeys.length; i++) {
      final key = fallbackKeys[i];
      print('   ${i + 1}. ${key.startsWith('AIza') ? 'корректный' : 'некорректный'} формат');
    }
    
    print('');
  }
  
  /// Тест 3: Проверка прокси конфигурации
  static Future<void> _testProxyConfiguration() async {
    print('🔒 Тест 3: Проверка прокси конфигурации...');
    
    // Основной прокси
    final mainProxy = EnvConfig.allProxy;
    if (mainProxy.isNotEmpty) {
      print('   ✅ Основной прокси: ${mainProxy.split('@')[1] ?? mainProxy}');
    } else {
      print('   ⚠️ Основной прокси: не установлен');
    }
    
    // Резервные прокси
    final backupProxies = EnvConfig.backupProxies;
    print('   📊 Резервных прокси: ${backupProxies.length}');
    for (var i = 0; i < backupProxies.length; i++) {
      final proxy = backupProxies[i];
      print('   ${i + 1}. ${proxy.split('@')[1] ?? proxy}');
    }
    
    // Текущий прокси
    final currentProxy = EnvConfig.getCurrentProxy();
    if (currentProxy.isNotEmpty) {
      print('   🎯 Текущий прокси: ${currentProxy.split('@')[1] ?? currentProxy}');
    } else {
      print('   ❌ Текущий прокси: не определен');
    }
    
    print('');
  }
  
  /// Тест 4: Проверка валидации конфигурации
  static Future<void> _testConfigurationValidation() async {
    print('✅ Тест 4: Проверка валидации конфигурации...');
    
    final validation = EnvConfig.validateConfiguration();
    
    print('   OpenAI настроен: ${validation['openai_configured'] ?? false ? '✅' : '❌'}');
    print('   Google настроен: ${validation['google_configured'] ?? false ? '✅' : '❌'}');
    print('   Прокси настроен: ${validation['proxy_configured'] ?? false ? '✅' : '❌'}');
    print('   Есть резервные прокси: ${validation['has_backup_proxies'] ?? false ? '✅' : '❌'}');
    print('   Есть резервные Google ключи: ${validation['has_google_fallback'] ?? false ? '✅' : '❌'}');
    
    // Проверка готовности к работе
    final isReady = validation['openai_configured']! || validation['google_configured']!;
    print('   🚀 Готовность к работе: ${isReady ? '✅' : '❌'}');
    
    if (!isReady) {
      print('   ⚠️ Внимание: Ни один AI провайдер не настроен!');
    }
    
    print('');
  }
  
  /// Тест 5: Проверка методов получения конфигурации
  static Future<void> _testConfigurationMethods() async {
    print('🔧 Тест 5: Проверка методов получения конфигурации...');
    
    // Тест получения следующего прокси
    final currentProxy = EnvConfig.getCurrentProxy();
    final nextProxy = EnvConfig.getNextBackupProxy(currentProxy);
    if (nextProxy != null) {
      print('   ✅ Следующий прокси: ${nextProxy.split('@')[1] ?? nextProxy}');
    } else {
      print('   ⚠️ Следующий прокси: не найден');
    }
    
    // Тест получения следующего Google ключа
    final currentGoogleKey = EnvConfig.googleApiKey;
    final nextGoogleKey = EnvConfig.getNextGoogleApiKey(currentGoogleKey);
    if (nextGoogleKey != null) {
      print('   ✅ Следующий Google ключ: ${nextGoogleKey.startsWith('AIza') ? 'корректный' : 'некорректный'}');
    } else {
      print('   ⚠️ Следующий Google ключ: не найден');
    }
    
    // Тест флагов готовности
    print('   🎯 Флаги готовности:');
    print('   - OpenAI готов: ${EnvConfig.isOpenAIConfigured ? '✅' : '❌'}');
    print('   - Google готов: ${EnvConfig.isGoogleConfigured ? '✅' : '❌'}');
    print('   - Прокси готов: ${EnvConfig.isProxyConfigured ? '✅' : '❌'}');
    print('   - Есть резервные прокси: ${EnvConfig.hasBackupProxies ? '✅' : '❌'}');
    print('   - Есть резервные Google ключи: ${EnvConfig.hasGoogleFallbackKeys ? '✅' : '❌'}');
    
    print('');
  }
}

/// Запуск тестов
void main() async {
  await EnvConfigTester.runAllTests();
}
