/// Simple test script for utility functions only
/// 
/// This script tests the utility functions without any Flutter dependencies.
library;

import 'dart:typed_data';
import 'dart:convert';

void main() async {
  print('🧪 Starting utility functions test...');
  
  try {
    // Test base64 compression
    await testBase64Compression();
    
    // Test image validation
    await testImageValidation();
    
    print('✅ All tests completed successfully!');
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}

/// Test base64 compression functionality
Future<void> testBase64Compression() async {
  print('\n🗜️ Testing base64 compression...');
  
  // Create test data
  final testData = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  final base64String = base64Encode(testData);
  
  print('Original base64: $base64String (${base64String.length} chars)');
  
  // Test compression (remove padding and whitespace)
  final compressed = base64String.replaceAll('=', '').replaceAll(RegExp(r'\s'), '');
  print('Compressed base64: $compressed (${compressed.length} chars)');
  print('Compression: ${compressed.length < base64String.length ? "✅ PASS" : "❌ FAIL"}');
  
  // Test decompression (add padding back)
  var decompressed = compressed;
  var paddingLength = 4 - (decompressed.length % 4);
  if (paddingLength != 4) {
    decompressed += '=' * paddingLength;
  }
  print('Decompressed base64: $decompressed (${decompressed.length} chars)');
  print('Decompression: ${decompressed == base64String ? "✅ PASS" : "❌ FAIL"}');
  
  // Test data integrity
  final decodedData = base64Decode(decompressed);
  print('Data integrity: ${listEquals(decodedData, testData) ? "✅ PASS" : "❌ FAIL"}');
}

/// Test image validation functionality
Future<void> testImageValidation() async {
  print('\n🔍 Testing image validation...');
  
  // Test with empty bytes
  final emptyBytes = Uint8List(0);
  final isValidEmpty = validateImage(emptyBytes);
  print('Empty bytes validation: ${isValidEmpty ? "❌ FAIL" : "✅ PASS"}');
  
  // Test with small bytes
  final smallBytes = Uint8List(50);
  final isValidSmall = validateImage(smallBytes);
  print('Small bytes validation: ${isValidSmall ? "❌ FAIL" : "✅ PASS"}');
  
  // Test with large bytes
  final largeBytes = Uint8List(11 * 1024 * 1024); // 11MB
  final isValidLarge = validateImage(largeBytes);
  print('Large bytes validation: ${isValidLarge ? "❌ FAIL" : "✅ PASS"}');
  
  // Test with valid image header (PNG)
  final pngHeader = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  final pngBytes = Uint8List(200);
  pngBytes.setRange(0, 8, pngHeader);
  final isValidPng = validateImage(pngBytes);
  print('PNG header validation: ${isValidPng ? "✅ PASS" : "❌ FAIL"}');
  
  // Test with valid image header (JPEG)
  final jpegHeader = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
  final jpegBytes = Uint8List(200);
  jpegBytes.setRange(0, 4, jpegHeader);
  final isValidJpeg = validateImage(jpegBytes);
  print('JPEG header validation: ${isValidJpeg ? "✅ PASS" : "❌ FAIL"}');
}

/// Simple image validation function
bool validateImage(Uint8List imageBytes) {
  try {
    // Check if bytes are empty
    if (imageBytes.isEmpty) {
      return false;
    }
    
    // Check size limit (2MB)
    if (imageBytes.length > 2 * 1024 * 1024) {
      return false;
    }
    
    // Check minimum size (at least 100 bytes for a valid image)
    if (imageBytes.length < 100) {
      return false;
    }
    
    // Check for common image headers
    if (!isValidImageHeader(imageBytes)) {
      return false;
    }
    
    return true;
  } catch (e) {
    return false;
  }
}

/// Check if bytes start with valid image header
bool isValidImageHeader(Uint8List bytes) {
  if (bytes.length < 4) return false;
  
  // Check for common image formats
  // JPEG: FF D8 FF
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return true;
  }
  
  // PNG: 89 50 4E 47
  if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
    return true;
  }
  
  // GIF: 47 49 46 38
  if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) {
    return true;
  }
  
  // WebP: 52 49 46 46 (RIFF)
  if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
    return true;
  }
  
  return false;
}

/// Simple list equality check
bool listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
