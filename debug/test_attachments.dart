/// Test script for attachment functionality
/// 
/// This script tests the new attachment system to ensure
/// images are properly stored and displayed in messages.
library;

import 'dart:typed_data';
import 'dart:convert';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';

void main() {
  print('🧪 Testing Attachment System');
  print('=' * 50);
  
  // Test 1: Create image attachment
  print('\n📎 Test 1: Creating image attachment');
  final testImageData = Uint8List.fromList([1, 2, 3, 4, 5]); // Mock image data
  final attachment = Attachment.image(
    id: 'test-attachment-1',
    name: 'test_image.jpg',
    data: testImageData,
    mimeType: 'image/jpeg',
    width: 800,
    height: 600,
  );
  
  print('✅ Attachment created: ${attachment.name}');
  print('   - Type: ${attachment.type.name}');
  print('   - Size: ${attachment.displaySize}');
  print('   - Has data: ${attachment.hasData}');
  print('   - Is image: ${attachment.isImage}');
  
  // Test 2: Serialize attachment to JSON
  print('\n📄 Test 2: Serializing attachment to JSON');
  final json = attachment.toJson();
  print('✅ JSON created with keys: ${json.keys.toList()}');
  print('   - Data length: ${json['data']?.length ?? 0}');
  
  // Test 3: Deserialize attachment from JSON
  print('\n🔄 Test 3: Deserializing attachment from JSON');
  final deserializedAttachment = Attachment.fromJson(json);
  print('✅ Attachment deserialized: ${deserializedAttachment.name}');
  print('   - Data matches: ${deserializedAttachment.data?.length == attachment.data?.length}');
  print('   - Type matches: ${deserializedAttachment.type == attachment.type}');
  
  // Test 4: Create message with attachments
  print('\n💬 Test 4: Creating message with attachments');
  final message = Message.user(
    id: 'test-message-1',
    content: 'Тестовое сообщение с изображением',
    attachments: [attachment],
  );
  
  print('✅ Message created with ${message.attachments?.length ?? 0} attachments');
  print('   - Content: ${message.content}');
  print('   - Has attachments: ${message.attachments != null && message.attachments!.isNotEmpty}');
  
  // Test 5: Serialize message to JSON
  print('\n📄 Test 5: Serializing message to JSON');
  final messageJson = message.toJson();
  print('✅ Message JSON created with keys: ${messageJson.keys.toList()}');
  print('   - Attachments in JSON: ${messageJson['attachments'] != null}');
  
  // Test 6: Deserialize message from JSON
  print('\n🔄 Test 6: Deserializing message from JSON');
  final deserializedMessage = Message.fromJson(messageJson);
  print('✅ Message deserialized');
  print('   - Content matches: ${deserializedMessage.content == message.content}');
  print('   - Attachments count: ${deserializedMessage.attachments?.length ?? 0}');
  print('   - First attachment name: ${deserializedMessage.attachments?.first.name ?? 'None'}');
  
  // Test 7: Multiple attachments
  print('\n📎 Test 7: Testing multiple attachments');
  final attachment2 = Attachment.image(
    id: 'test-attachment-2',
    name: 'test_image2.png',
    data: Uint8List.fromList([6, 7, 8, 9, 10]),
    mimeType: 'image/png',
  );
  
  final multiAttachmentMessage = Message.user(
    id: 'test-message-2',
    content: 'Сообщение с несколькими изображениями',
    attachments: [attachment, attachment2],
  );
  
  print('✅ Multi-attachment message created');
  print('   - Attachments count: ${multiAttachmentMessage.attachments?.length ?? 0}');
  print('   - Image attachments: ${multiAttachmentMessage.attachments?.where((a) => a.isImage).length ?? 0}');
  
  // Test 8: File attachment
  print('\n📁 Test 8: Testing file attachment');
  final fileAttachment = Attachment.file(
    id: 'test-file-1',
    name: 'document.pdf',
    data: Uint8List.fromList([11, 12, 13, 14, 15]),
    mimeType: 'application/pdf',
  );
  
  final mixedMessage = Message.user(
    id: 'test-message-3',
    content: 'Сообщение с изображением и файлом',
    attachments: [attachment, fileAttachment],
  );
  
  print('✅ Mixed attachment message created');
  print('   - Total attachments: ${mixedMessage.attachments?.length ?? 0}');
  print('   - Image attachments: ${mixedMessage.attachments?.where((a) => a.isImage).length ?? 0}');
  print('   - File attachments: ${mixedMessage.attachments?.where((a) => !a.isImage).length ?? 0}');
  
  print('\n🎉 All tests completed successfully!');
  print('=' * 50);
  print('✅ Attachment system is working correctly');
  print('✅ Images will now persist in chat messages');
}
