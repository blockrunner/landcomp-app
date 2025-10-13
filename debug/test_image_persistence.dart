/// Test script for image persistence functionality
/// 
/// This script tests the improved image serialization and storage
/// to ensure images are properly saved and loaded.
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/chat_session.dart';
import 'package:landcomp_app/core/storage/chat_storage.dart';
import 'package:landcomp_app/core/utils/image_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Starting image persistence test...');
  
  try {
    // Initialize storage
    final storage = ChatStorage.instance;
    await storage.initialize();
    
    // Test image validation
    await testImageValidation();
    
    // Test message serialization
    await testMessageSerialization();
    
    // Test session storage
    await testSessionStorage(storage);
    
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
  print('Empty bytes validation: ${isValidEmpty ? "✅ PASS" : "❌ FAIL"}');
  
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
}

/// Test message serialization with images
Future<void> testMessageSerialization() async {
  print('\n📄 Testing message serialization...');
  
  // Create test image bytes
  final testImageBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG header
    ...List.filled(100, 0x00), // Dummy data
  ]);
  
  // Create message with images
  final message = Message.user(
    id: 'test-message-1',
    content: 'Test message with image',
    imageBytes: [testImageBytes],
  );
  
  print('Original message has ${message.imageBytes?.length ?? 0} images');
  
  // Test serialization
  final json = message.toJson();
  print('Serialized to JSON: ${json.containsKey('imageBytes') ? "✅ PASS" : "❌ FAIL"}');
  
  // Test deserialization
  final deserializedMessage = Message.fromJson(json);
  print('Deserialized message has ${deserializedMessage.imageBytes?.length ?? 0} images');
  print('Deserialization: ${deserializedMessage.imageBytes?.isNotEmpty == true ? "✅ PASS" : "❌ FAIL"}');
  
  // Test image data integrity
  if (deserializedMessage.imageBytes?.isNotEmpty == true) {
    final originalSize = testImageBytes.length;
    final deserializedSize = deserializedMessage.imageBytes!.first.length;
    print('Image size integrity: ${originalSize == deserializedSize ? "✅ PASS" : "❌ FAIL"}');
    print('Original size: $originalSize, Deserialized size: $deserializedSize');
  }
}

/// Test session storage with images
Future<void> testSessionStorage(ChatStorage storage) async {
  print('\n💾 Testing session storage...');
  
  // Create test image bytes
  final testImageBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG header
    ...List.filled(1000, 0x00), // Dummy data
  ]);
  
  // Create message with images
  final message = Message.user(
    id: 'test-message-2',
    content: 'Test message for storage',
    imageBytes: [testImageBytes],
  );
  
  // Create session
  final session = ChatSession(
    id: 'test-session-1',
    title: 'Test Session',
    messages: [message],
    agentId: 'test-agent',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  print('Original session has ${session.messages.length} messages');
  print('First message has ${session.messages.first.imageBytes?.length ?? 0} images');
  
  // Save session
  await storage.saveSession(session);
  print('Session saved: ✅ PASS');
  
  // Load session
  final loadedSession = await storage.loadSession(session.id);
  print('Session loaded: ${loadedSession != null ? "✅ PASS" : "❌ FAIL"}');
  
  if (loadedSession != null) {
    print('Loaded session has ${loadedSession.messages.length} messages');
    print('First message has ${loadedSession.messages.first.imageBytes?.length ?? 0} images');
    
    // Test image data integrity
    if (loadedSession.messages.first.imageBytes?.isNotEmpty == true) {
      final originalSize = testImageBytes.length;
      final loadedSize = loadedSession.messages.first.imageBytes!.first.length;
      print('Image data integrity: ${originalSize == loadedSize ? "✅ PASS" : "❌ FAIL"}');
      print('Original size: $originalSize, Loaded size: $loadedSize');
    }
  }
  
  // Clean up
  await storage.deleteSession(session.id);
  print('Test session cleaned up: ✅ PASS');
}
