/// Демонстрационный тестовый скрипт для Gemini Image Generation
/// 
/// Этот скрипт показывает, как будет работать тест с реальными данными
library;

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Демонстрационный класс для тестирования Gemini Image Generation
class GeminiImageDemo {
  
  GeminiImageDemo({
    required this.testImagesDir,
    required this.outputDir,
  });
  static const String _modelName = 'gemini-2.5-flash-image-preview';
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent';
  static const String _prompt = 'объедини эти фото в один участок с красивым садом в скандинавском стиле сделай 3 отдельных вараинта и опиши каждый из них';
  
  final String testImagesDir;
  final String outputDir;

  /// Запуск демонстрации
  Future<void> runDemo() async {
    print('🎨 Демонстрация Gemini Image Generation');
    print('=======================================');
    print('');

    try {
      // Создаем папку для результатов
      await _createOutputDirectory();
      
      // Получаем список изображений
      final imageFiles = await _getImageFiles();
      print('📸 Найдено изображений: ${imageFiles.length}');
      
      if (imageFiles.isEmpty) {
        print('❌ Изображения не найдены в папке $testImagesDir');
        print('💡 Добавьте изображения в папку test-images для тестирования');
        return;
      }
      
      // Показываем информацию об изображениях
      await _showImageInfo(imageFiles);
      
      // Показываем, как будет выглядеть запрос
      await _showRequestExample(imageFiles);
      
      // Создаем пример ответа
      await _createExampleResponse();
      
      print('✅ Демонстрация завершена!');
      print('');
      print('🚀 Для запуска реального теста:');
      print('   1. Получите API ключ: https://aistudio.google.com/app/apikey');
      print('   2. Установите переменную: set GOOGLE_API_KEY=your_api_key_here');
      print('   3. Запустите: dart run debug/test_gemini_simple.dart');
      
    } catch (e) {
      print('❌ Ошибка во время демонстрации: $e');
      rethrow;
    }
  }

  /// Создание папки для результатов
  Future<void> _createOutputDirectory() async {
    final outputDirPath = Directory(outputDir);
    if (!await outputDirPath.exists()) {
      await outputDirPath.create(recursive: true);
      print('📁 Создана папка: $outputDir');
    }
  }

  /// Получение списка изображений
  Future<List<File>> _getImageFiles() async {
    final testDir = Directory(testImagesDir);
    if (!await testDir.exists()) {
      throw Exception('Папка $testImagesDir не существует');
    }

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final files = <File>[];
    
    await for (final entity in testDir.list()) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase();
        if (imageExtensions.contains(extension)) {
          files.add(entity);
        }
      }
    }
    
    return files;
  }

  /// Показ информации об изображениях
  Future<void> _showImageInfo(List<File> imageFiles) async {
    print('');
    print('📋 Информация об изображениях:');
    for (var i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final size = await file.length();
      final sizeKB = (size / 1024).round();
      print('   ${i + 1}. ${path.basename(file.path)} ($sizeKB KB)');
    }
  }

  /// Показ примера запроса
  Future<void> _showRequestExample(List<File> imageFiles) async {
    print('');
    print('📤 Пример запроса к Gemini API:');
    print('   URL: $_apiUrl?key=YOUR_API_KEY');
    print('   Модель: $_modelName');
    print('   Промпт: $_prompt');
    print('   Изображений: ${imageFiles.length}');
    
    // Показываем размер данных
    var totalSize = 0;
    for (final file in imageFiles) {
      totalSize += await file.length();
    }
    final totalSizeKB = (totalSize / 1024).round();
    print('   Общий размер изображений: $totalSizeKB KB');
    
    // Примерная оценка размера base64
    final estimatedBase64Size = (totalSize * 1.37 / 1024).round();
    print('   Примерный размер base64: $estimatedBase64Size KB');
  }

  /// Создание примера ответа
  Future<void> _createExampleResponse() async {
    print('');
    print('📥 Пример ответа от Gemini API:');
    
    // Создаем пример текстового ответа
    const exampleText = '''
Вариант 1: Минималистичный скандинавский сад
Этот дизайн сочетает в себе простоту и функциональность, характерные для скандинавского стиля. 
Используются натуральные материалы: дерево, камень, гравий. Растения подобраны с учетом 
климатических условий - хвойные деревья, вереск, мхи. Цветовая палитра сдержанная: 
зеленые, серые, бежевые тона с акцентами белого и черного.

Вариант 2: Современный скандинавский сад с акцентом на геометрию
В этом варианте преобладают четкие геометрические формы и линии. Дорожки выложены 
прямоугольными плитами, клумбы имеют строгие очертания. Используются современные 
материалы: кортен-сталь, бетон, стекло. Растительность минималистичная: 
декоративные травы, суккуленты, вечнозеленые кустарники.

Вариант 3: Уютный скандинавский сад с элементами хюгге
Этот дизайн создает атмосферу уюта и комфорта. Много деревянных элементов: 
скамейки, перголы, деревянные контейнеры. Растения подобраны для создания 
уютной атмосферы: лаванда, розы, декоративные травы. Добавлены элементы освещения 
и уютные уголки для отдыха.
''';

    // Сохраняем пример текста
    final textFile = File(path.join(outputDir, 'example_response.txt'));
    await textFile.writeAsString(exampleText);
    print('📄 Создан пример текстового ответа: example_response.txt');
    
    // Создаем пример изображений (заглушки)
    for (var i = 1; i <= 3; i++) {
      final exampleImage = File(path.join(outputDir, 'example_result_$i.jpg'));
      // Создаем пустой файл как заглушку
      await exampleImage.writeAsString('Пример изображения $i (заглушка)');
      print('🖼️ Создан пример изображения: example_result_$i.jpg');
    }
  }
}

/// Главная функция для запуска демонстрации
Future<void> main() async {
  print('🎨 Демонстрация Gemini Image Generation');
  print('=======================================');
  print('');

  // Определяем пути
  final currentDir = Directory.current.path;
  final testImagesDir = path.join(currentDir, 'test-images');
  final outputDir = path.join(testImagesDir, 'test-gemini');

  // Создаем и запускаем демонстрацию
  final demo = GeminiImageDemo(
    testImagesDir: testImagesDir,
    outputDir: outputDir,
  );

  try {
    await demo.runDemo();
  } catch (e) {
    print('');
    print('💥 Демонстрация завершилась с ошибкой: $e');
    exit(1);
  }
}
