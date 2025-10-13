/// Test script for smart image selection functionality
/// 
/// This script tests the Phase 2 implementation of smart image selection
/// based on user intent classification.
library;

import 'dart:typed_data';
import 'package:landcomp_app/core/orchestrator/agent_orchestrator.dart';
import 'package:landcomp_app/core/orchestrator/intent_classifier.dart';
import 'package:landcomp_app/core/orchestrator/context_manager.dart';
import 'package:landcomp_app/shared/models/intent.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';

/// Test scenarios for smart image selection
class SmartImageSelectionTest {
  static Future<void> runAllTests() async {
    print('🧪 Starting Smart Image Selection Tests');
    print('=' * 50);
    
    try {
      // Initialize orchestrator
      await AgentOrchestrator.instance.initialize();
      
      // Test scenarios
      await _testScenario1_NewImageAnalysis();
      await _testScenario2_ReferenceSpecificImage();
      await _testScenario3_CompareMultipleImages();
      await _testScenario4_GenerateBasedOnImage();
      await _testScenario5_NoImageNeeded();
      await _testScenario6_AgentGeneratedImageReference();
      
      print('\n✅ All tests completed successfully!');
      
    } catch (e) {
      print('\n❌ Test failed: $e');
    } finally {
      await AgentOrchestrator.instance.dispose();
    }
  }
  
  /// Test Scenario 1: New image analysis
  /// "Проанализируй это фото участка" + 1 new image
  static Future<void> _testScenario1_NewImageAnalysis() async {
    print('\n📸 Test 1: New Image Analysis');
    print('-' * 30);
    
    final userMessage = 'Проанализируй это фото участка';
    final conversationHistory = <Message>[];
    final attachments = [_createTestImageAttachment('test_image_1.jpg')];
    
    // Test intent classification
    final context = await ContextManager.instance.buildContext(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      attachments: attachments,
    );
    
    final intent = await IntentClassifier.instance.classifyIntent(userMessage, context);
    print('Intent: ${intent.type.name}');
    print('Image Intent: ${intent.imageIntent?.name}');
    print('Images Needed: ${intent.imagesNeeded}');
    
    // Test smart image selection
    final relevantImages = await ContextManager.instance.getRelevantImages(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      intent: intent,
      currentAttachments: attachments,
    );
    
    print('Selected Images: ${relevantImages.length}');
    print('Expected: 1 (new image)');
    
    // Verify result
    if (relevantImages.length == 1 && intent.imageIntent == ImageIntent.analyzeNew) {
      print('✅ Test 1 PASSED');
    } else {
      print('❌ Test 1 FAILED');
    }
  }
  
  /// Test Scenario 2: Reference specific image
  /// "А что насчет первого фото?" (no new images)
  static Future<void> _testScenario2_ReferenceSpecificImage() async {
    print('\n🔍 Test 2: Reference Specific Image');
    print('-' * 30);
    
    final userMessage = 'А что насчет первого фото?';
    final conversationHistory = [
      Message.user(
        id: 'msg1',
        content: 'Вот мой участок',
        attachments: [_createTestImageAttachment('image1.jpg')],
      ),
      Message.ai(
        id: 'msg2',
        content: 'Вижу ваш участок, есть несколько идей...',
        agentId: 'test_agent',
      ),
    ];
    final attachments = <Attachment>[];
    
    // Test intent classification
    final context = await ContextManager.instance.buildContext(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      attachments: attachments,
    );
    
    final intent = await IntentClassifier.instance.classifyIntent(userMessage, context);
    print('Intent: ${intent.type.name}');
    print('Image Intent: ${intent.imageIntent?.name}');
    print('Referenced Indices: ${intent.referencedImageIndices}');
    
    // Test smart image selection
    final relevantImages = await ContextManager.instance.getRelevantImages(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      intent: intent,
      currentAttachments: attachments,
    );
    
    print('Selected Images: ${relevantImages.length}');
    print('Expected: 1 (first image from history)');
    
    // Verify result
    if (relevantImages.length == 1 && intent.imageIntent == ImageIntent.referenceSpecific) {
      print('✅ Test 2 PASSED');
    } else {
      print('❌ Test 2 FAILED');
    }
  }
  
  /// Test Scenario 3: Compare multiple images
  /// "Сравни эти два варианта" + 2 new images
  static Future<void> _testScenario3_CompareMultipleImages() async {
    print('\n🔄 Test 3: Compare Multiple Images');
    print('-' * 30);
    
    final userMessage = 'Сравни эти два варианта';
    final conversationHistory = <Message>[];
    final attachments = [
      _createTestImageAttachment('option1.jpg'),
      _createTestImageAttachment('option2.jpg'),
    ];
    
    // Test intent classification
    final context = await ContextManager.instance.buildContext(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      attachments: attachments,
    );
    
    final intent = await IntentClassifier.instance.classifyIntent(userMessage, context);
    print('Intent: ${intent.type.name}');
    print('Image Intent: ${intent.imageIntent?.name}');
    print('Images Needed: ${intent.imagesNeeded}');
    
    // Test smart image selection
    final relevantImages = await ContextManager.instance.getRelevantImages(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      intent: intent,
      currentAttachments: attachments,
    );
    
    print('Selected Images: ${relevantImages.length}');
    print('Expected: 2 (both new images)');
    
    // Verify result
    if (relevantImages.length == 2 && intent.imageIntent == ImageIntent.compareMultiple) {
      print('✅ Test 3 PASSED');
    } else {
      print('❌ Test 3 FAILED');
    }
  }
  
  /// Test Scenario 4: Generate based on image
  /// "Сгенерируй план на основе этого фото" + 1 image
  static Future<void> _testScenario4_GenerateBasedOnImage() async {
    print('\n🎨 Test 4: Generate Based On Image');
    print('-' * 30);
    
    final userMessage = 'Сгенерируй план на основе этого фото';
    final conversationHistory = <Message>[];
    final attachments = [_createTestImageAttachment('base_image.jpg')];
    
    // Test intent classification
    final context = await ContextManager.instance.buildContext(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      attachments: attachments,
    );
    
    final intent = await IntentClassifier.instance.classifyIntent(userMessage, context);
    print('Intent: ${intent.type.name}');
    print('Image Intent: ${intent.imageIntent?.name}');
    print('Images Needed: ${intent.imagesNeeded}');
    
    // Test smart image selection
    final relevantImages = await ContextManager.instance.getRelevantImages(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      intent: intent,
      currentAttachments: attachments,
    );
    
    print('Selected Images: ${relevantImages.length}');
    print('Expected: 1 (new image, limited to 1 for generation)');
    
    // Verify result
    if (relevantImages.length == 1 && intent.imageIntent == ImageIntent.generateBased) {
      print('✅ Test 4 PASSED');
    } else {
      print('❌ Test 4 FAILED');
    }
  }
  
  /// Test Scenario 5: No image needed
  /// "Какие растения подходят для тени?" (no images)
  static Future<void> _testScenario5_NoImageNeeded() async {
    print('\n🌿 Test 5: No Image Needed');
    print('-' * 30);
    
    final userMessage = 'Какие растения подходят для тени?';
    final conversationHistory = <Message>[];
    final attachments = <Attachment>[];
    
    // Test intent classification
    final context = await ContextManager.instance.buildContext(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      attachments: attachments,
    );
    
    final intent = await IntentClassifier.instance.classifyIntent(userMessage, context);
    print('Intent: ${intent.type.name}');
    print('Image Intent: ${intent.imageIntent?.name}');
    print('Images Needed: ${intent.imagesNeeded}');
    
    // Test smart image selection
    final relevantImages = await ContextManager.instance.getRelevantImages(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      intent: intent,
      currentAttachments: attachments,
    );
    
    print('Selected Images: ${relevantImages.length}');
    print('Expected: 0 (no images needed)');
    
    // Verify result
    if (relevantImages.isEmpty && intent.imageIntent == ImageIntent.noImageNeeded) {
      print('✅ Test 5 PASSED');
    } else {
      print('❌ Test 5 FAILED');
    }
  }
  
  /// Test Scenario 6: Agent generated image reference
  /// Agent generated image, user asks "Измени цвет дорожки"
  static Future<void> _testScenario6_AgentGeneratedImageReference() async {
    print('\n🤖 Test 6: Agent Generated Image Reference');
    print('-' * 30);
    
    final userMessage = 'Измени цвет дорожки';
    final conversationHistory = [
      Message.user(
        id: 'msg1',
        content: 'Создай дизайн участка',
      ),
      Message.ai(
        id: 'msg2',
        content: 'Вот дизайн вашего участка',
        agentId: 'test_agent',
        attachments: [_createTestImageAttachment('generated_design.jpg')],
      ),
    ];
    final attachments = <Attachment>[];
    
    // Test intent classification
    final context = await ContextManager.instance.buildContext(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      attachments: attachments,
    );
    
    final intent = await IntentClassifier.instance.classifyIntent(userMessage, context);
    print('Intent: ${intent.type.name}');
    print('Image Intent: ${intent.imageIntent?.name}');
    print('Images Needed: ${intent.imagesNeeded}');
    
    // Test smart image selection
    final relevantImages = await ContextManager.instance.getRelevantImages(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      intent: intent,
      currentAttachments: attachments,
    );
    
    print('Selected Images: ${relevantImages.length}');
    print('Expected: 1 (recent image from agent response)');
    
    // Verify result
    if (relevantImages.length == 1 && intent.imageIntent == ImageIntent.analyzeRecent) {
      print('✅ Test 6 PASSED');
    } else {
      print('❌ Test 6 FAILED');
    }
  }
  
  /// Create a test image attachment
  static Attachment _createTestImageAttachment(String name) {
    // Create dummy image data (1x1 pixel JPEG)
    final dummyImageData = Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
      0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
      0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
      0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
      0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
      0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xFF, 0xC4,
      0x00, 0x14, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x0C,
      0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F, 0x00, 0x80, 0xFF, 0xD9
    ]);
    
    return Attachment.image(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      data: dummyImageData,
      mimeType: 'image/jpeg',
    );
  }
}

/// Main function to run tests
Future<void> main() async {
  await SmartImageSelectionTest.runAllTests();
}
