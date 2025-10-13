/// Простой скрипт для запуска теста Gemini Image Generation
/// 
/// Запуск: dart run debug/run_gemini_test.dart
library;

import 'dart:io';
import 'test_gemini_image_generation.dart';
import 'package:landcomp_app/core/config/env_config.dart';

void main() async {
  print('🎨 Запуск теста Gemini Image Generation');
  print('=======================================');
  print('');

  // Проверяем наличие API ключа
  final apiKey = EnvConfig.googleApiKey;
  if (apiKey.isEmpty) {
    print('❌ Ошибка: Не найден GOOGLE_API_KEY');
    print('');
    print('💡 Установите переменную окружения:');
    print('   Windows: set GOOGLE_API_KEY=your_api_key_here');
    print('   Linux/Mac: export GOOGLE_API_KEY=your_api_key_here');
    print('');
    print('🔑 Получить API ключ можно здесь: https://aistudio.google.com/app/apikey');
    exit(1);
  }

  // Получаем настройки прокси
  final proxyUrl = EnvConfig.getCurrentProxy();
  final backupProxies = EnvConfig.backupProxies;

  print('✅ API ключ найден');
  print('🤖 Модель: gemini-2.5-flash-image-preview');
  print('📝 Промпт: объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них');
  if (proxyUrl.isNotEmpty) {
    print('🌐 Прокси: $proxyUrl');
  }
  if (backupProxies.isNotEmpty) {
    print('🔄 Резервные прокси: ${backupProxies.length}');
  }
  print('');

  // Запускаем тест
  try {
    final currentDir = Directory.current.path;
    final testImagesDir = '$currentDir/test-images';
    final outputDir = '$testImagesDir/test-gemini';

    final test = GeminiImageTest(
      apiKey: apiKey,
      testImagesDir: testImagesDir,
      outputDir: outputDir,
      proxyUrl: proxyUrl.isNotEmpty ? proxyUrl : null,
      backupProxies: backupProxies,
    );

    await test.runTest();
  } catch (e) {
    print('💥 Ошибка: $e');
    exit(1);
  }
}
