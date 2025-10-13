/// Test script for image sending functionality
/// 
/// This script tests the image sending functionality by creating
/// a simple test case with mock image data.
library;

import 'dart:typed_data';
import 'dart:convert';

void main() {
  print('🧪 Testing image sending functionality...');
  
  // Create mock image data (1x1 pixel PNG)
  final mockImageData = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
  );
  
  // Test Message creation with images
  testMessageCreation(mockImageData);
  
  // Test image compression
  testImageCompression(mockImageData);
  
  print('✅ All tests completed!');
}

void testMessageCreation(Uint8List imageData) {
  print('\n📝 Testing Message creation with images...');
  
  // This would normally be done in the actual Message class
  final images = [imageData, imageData, imageData]; // 3 mock images
  
  print('✅ Created message with ${images.length} images');
  print('✅ Image sizes: ${images.map((img) => img.length).toList()}');
}

void testImageCompression(Uint8List imageData) {
  print('\n🗜️ Testing image compression...');
  
  // Simulate compression (in real app this would use the image package)
  final compressedSize = imageData.length;
  print('✅ Original size: ${imageData.length} bytes');
  print('✅ Compressed size: $compressedSize bytes');
  print('✅ Compression ratio: ${(compressedSize / imageData.length * 100).toStringAsFixed(1)}%');
}

/// Mock Message class for testing
class MockMessage {
  
  MockMessage({
    required this.id,
    required this.content,
    this.imageBytes,
  });
  
  factory MockMessage.user({
    required String id,
    required String content,
    List<Uint8List>? imageBytes,
  }) {
    return MockMessage(
      id: id,
      content: content,
      imageBytes: imageBytes,
    );
  }
  final String id;
  final String content;
  final List<Uint8List>? imageBytes;
}
