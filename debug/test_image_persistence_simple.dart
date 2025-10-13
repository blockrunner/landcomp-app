/// Simple test script for image persistence functionality
/// 
/// This script tests the improved image serialization and storage
/// without Flutter dependencies.
library;

import 'dart:typed_data';
import 'dart:convert';
import 'package:landcomp_app/core/utils/image_utils.dart';
import 'package:landcomp_app/core/utils/json_utils.dart';

void main() async {
  print('🧪 Starting simple image persistence test...');
  
  try {
    // Test image validation
    await testImageValidation();
    
    // Test JSON compression
    await testJsonCompression();
    
    // Test base64 compression
    await testBase64Compression();
    
    print('✅ All tests completed successfully!');
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}

/// Test image validation functionality
Future<void> testImageValidation() async {
  print('\n🔍 Testing image validation...');
  
  // Test with empty bytes
  final emptyBytes = Uint8List(0);
  final isValidEmpty = ImageUtils.validateImage(emptyBytes);
  print('Empty bytes validation: ${isValidEmpty ? "❌ FAIL" : "✅ PASS"}');
  
  // Test with small bytes
  final smallBytes = Uint8List(50);
  final isValidSmall = ImageUtils.validateImage(smallBytes);
  print('Small bytes validation: ${isValidSmall ? "❌ FAIL" : "✅ PASS"}');
  
  // Test with large bytes
  final largeBytes = Uint8List(11 * 1024 * 1024); // 11MB
  final isValidLarge = ImageUtils.validateImage(largeBytes);
  print('Large bytes validation: ${isValidLarge ? "❌ FAIL" : "✅ PASS"}');
  
  // Test with valid image header (PNG)
  final pngHeader = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  final pngBytes = Uint8List(200);
  pngBytes.setRange(0, 8, pngHeader);
  final isValidPng = ImageUtils.validateImage(pngBytes);
  print('PNG header validation: ${isValidPng ? "✅ PASS" : "❌ FAIL"}');
  
  // Test with valid image header (JPEG)
  final jpegHeader = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
  final jpegBytes = Uint8List(200);
  jpegBytes.setRange(0, 4, jpegHeader);
  final isValidJpeg = ImageUtils.validateImage(jpegBytes);
  print('JPEG header validation: ${isValidJpeg ? "✅ PASS" : "❌ FAIL"}');
}

/// Test JSON compression functionality
Future<void> testJsonCompression() async {
  print('\n🗜️ Testing JSON compression...');
  
  // Create test JSON with image data
  final testJson = {
    'id': 'test-message-1',
    'content': 'Test message with image',
    'imageBytes': [
      base64Encode(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])),
      base64Encode(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])),
    ],
  };
  
  // Test compression
  final compressed = JsonUtils.compressJson(testJson);
  print('JSON compression: ${compressed.length < jsonEncode(testJson).length ? "✅ PASS" : "❌ FAIL"}');
  
  // Test optimization
  final optimized = JsonUtils.optimizeImageData(testJson);
  print('Image data optimization: ${optimized.containsKey('imageBytes') ? "✅ PASS" : "❌ FAIL"}');
  
  // Test restoration
  final restored = JsonUtils.restoreImageData(optimized);
  print('Image data restoration: ${restored.containsKey('imageBytes') ? "✅ PASS" : "❌ FAIL"}');
  
  // Test size calculation
  final size = JsonUtils.calculateJsonSize(testJson);
  print('Size calculation: ${size > 0 ? "✅ PASS" : "❌ FAIL"} ($size bytes)');
}

/// Test base64 compression functionality
Future<void> testBase64Compression() async {
  print('\n🗜️ Testing base64 compression...');
  
  // Create test base64 string
  final testData = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  final base64String = base64Encode(testData);
  
  print('Original base64: $base64String (${base64String.length} chars)');
  
  // Test compression
  final compressed = JsonUtils.compressBase64(base64String);
  print('Compressed base64: $compressed (${compressed.length} chars)');
  print('Compression: ${compressed.length < base64String.length ? "✅ PASS" : "❌ FAIL"}');
  
  // Test decompression
  final decompressed = JsonUtils.decompressBase64(compressed);
  print('Decompressed base64: $decompressed (${decompressed.length} chars)');
  print('Decompression: ${decompressed == base64String ? "✅ PASS" : "❌ FAIL"}');
  
  // Test data integrity
  final decodedData = base64Decode(decompressed);
  print('Data integrity: ${listEquals(decodedData, testData) ? "✅ PASS" : "❌ FAIL"}');
}

/// Simple list equality check
bool listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
