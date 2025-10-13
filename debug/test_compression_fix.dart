import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:image/image.dart' as img;

/// Тестовый скрипт для проверки исправления сжатия изображений
/// Проверяет, что OpenAI теперь получает сжатые изображения
void main() async {
  print('🧪 Тестирование исправления сжатия изображений');
  
  // Тест с реальной картинкой
  await testImageCompression();
}

/// Тест сжатия изображения
Future<void> testImageCompression() async {
  print('\n📸 Тест: Сжатие изображения для OpenAI');
  
  try {
    // Загружаем тестовую картинку
    final imageFile = File('../test-images/test_image2.jpg');
    if (!await imageFile.exists()) {
      print('❌ Тестовая картинка не найдена: ../test-images/test_image2.jpg');
      return;
    }
    
    final imageBytes = await imageFile.readAsBytes();
    print('📸 Размер оригинальной картинки: ${imageBytes.length} bytes');
    
    // Сжимаем картинку как в исправленном коде (100KB)
    final compressedImage = await compressImage(imageBytes, maxSizeKb: 100);
    print('📸 Размер сжатой картинки: ${compressedImage.length} bytes');
    
    // Кодируем в base64
    final base64Image = base64Encode(compressedImage);
    print('📸 Размер base64: ${base64Image.length} символов');
    
    // Отправляем запрос в OpenAI
    final response = await sendToOpenAI(
      message: 'Что ты видишь на этой картинке? Опиши подробно.',
      imageBase64: base64Image,
    );
    
    print('✅ Ответ OpenAI: $response');
    
  } catch (e) {
    print('❌ Ошибка в тесте: $e');
  }
}

/// Сжатие изображения (копия из исправленного кода)
Future<Uint8List> compressImage(Uint8List imageData, {int maxSizeKb = 100}) async {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) {
      print('⚠️ Не удалось декодировать изображение');
      return imageData;
    }

    final originalSizeKb = imageData.length / 1024;
    print('📸 Оригинал: ${image.width}x${image.height}, ${originalSizeKb.toStringAsFixed(1)}KB');

    if (originalSizeKb <= maxSizeKb) {
      print('✅ Изображение уже достаточно маленькое');
      return imageData;
    }

    // Вычисляем коэффициент сжатия
    final targetPixels = (maxSizeKb * 1024 * 10) / 3; // RGB = 3 bytes per pixel
    final currentPixels = image.width * image.height;
    final ratio = sqrt(targetPixels / currentPixels);
    
    final newWidth = (image.width * ratio).toInt();
    final newHeight = (image.height * ratio).toInt();

    print('📸 Изменяем размер до ${newWidth}x${newHeight}');
    final resized = img.copyResize(image, width: newWidth, height: newHeight);

    // Кодируем как JPEG с качеством 85
    final compressed = Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    final compressedSizeKb = compressed.length / 1024;

    print('✅ Сжато: ${compressedSizeKb.toStringAsFixed(1)}KB (${((1 - compressedSizeKb / originalSizeKb) * 100).toStringAsFixed(1)}% сжатие)');
    
    return compressed;
  } catch (e) {
    print('⚠️ Ошибка сжатия: $e, возвращаем оригинал');
    return imageData;
  }
}

/// Отправка запроса в OpenAI через прокси
Future<String> sendToOpenAI({
  required String message,
  required String imageBase64,
  String systemPrompt = 'Ты полезный помощник.',
}) async {
  final dio = Dio();
  
  // Настраиваем прокси
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.findProxy = (uri) {
      return 'PROXY localhost:3001';
    };
    return client;
  };
  
  // Настраиваем таймауты
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 60);
  
  // Добавляем логирование
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('🌐 $obj'),
  ));
  
  try {
    print('🚀 Отправляем запрос в OpenAI...');
    
    final response = await dio.post(
      'http://localhost:3001/proxy/openai/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
      data: {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': message,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$imageBase64',
                },
              },
            ],
          },
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      },
    );
    
    print('📊 Статус ответа: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = response.data;
      final content = data['choices'][0]['message']['content'] as String;
      return content;
    } else {
      final errorData = response.data;
      final errorMessage = errorData?['error']?['message'] ?? 'Неизвестная ошибка';
      throw Exception('OpenAI API error (${response.statusCode}): $errorMessage');
    }
    
  } catch (e) {
    print('❌ Ошибка запроса: $e');
    rethrow;
  }
}
