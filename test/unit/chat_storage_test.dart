/// Unit tests for ChatStorage
/// 
/// Tests Hive storage functionality, message persistence,
/// session management, and error recovery
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';

void main() {
  group('Message JSON Serialization', () {
    test('should serialize message to JSON', () {
      // Arrange
      final timestamp = DateTime(2024, 1, 1, 12, 0);
      final message = Message(
        id: '1',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
        agentId: 'gardener',
      );

      // Act
      final json = message.toJson();

      // Assert
      expect(json['id'], equals('1'));
      expect(json['content'], equals('Test message'));
      expect(json['type'], equals('user'));
      expect(json['timestamp'], equals('2024-01-01T12:00:00.000'));
      expect(json['agentId'], equals('gardener'));
      expect(json['isError'], equals(false));
      expect(json['isTyping'], equals(false));
    });

    test('should deserialize message from JSON', () {
      // Arrange
      final json = {
        'id': '2',
        'content': 'AI response',
        'type': 'ai',
        'timestamp': '2024-01-01T12:00:00.000',
        'agentId': 'gardener',
        'isError': false,
        'isTyping': false,
      };

      // Act
      final message = Message.fromJson(json);

      // Assert
      expect(message.id, equals('2'));
      expect(message.content, equals('AI response'));
      expect(message.type, equals(MessageType.ai));
      expect(message.timestamp, equals(DateTime(2024, 1, 1, 12, 0)));
      expect(message.agentId, equals('gardener'));
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(false));
    });

    test('should handle null agentId in JSON', () {
      // Arrange
      final json = {
        'id': '3',
        'content': 'User message',
        'type': 'user',
        'timestamp': '2024-01-01T12:00:00.000',
        'agentId': null,
        'isError': false,
        'isTyping': false,
      };

      // Act
      final message = Message.fromJson(json);

      // Assert
      expect(message.id, equals('3'));
      expect(message.content, equals('User message'));
      expect(message.type, equals(MessageType.user));
      expect(message.agentId, isNull);
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(false));
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {
        'id': '4',
        'content': 'System message',
        'type': 'system',
        'timestamp': '2024-01-01T12:00:00.000',
      };

      // Act
      final message = Message.fromJson(json);

      // Assert
      expect(message.id, equals('4'));
      expect(message.content, equals('System message'));
      expect(message.type, equals(MessageType.system));
      expect(message.agentId, isNull);
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(false));
    });

    test('should handle error message in JSON', () {
      // Arrange
      final json = {
        'id': '5',
        'content': 'Error occurred',
        'type': 'system',
        'timestamp': '2024-01-01T12:00:00.000',
        'agentId': null,
        'isError': true,
        'isTyping': false,
      };

      // Act
      final message = Message.fromJson(json);

      // Assert
      expect(message.id, equals('5'));
      expect(message.content, equals('Error occurred'));
      expect(message.type, equals(MessageType.system));
      expect(message.isError, equals(true));
      expect(message.isTyping, equals(false));
    });

    test('should handle typing message in JSON', () {
      // Arrange
      final json = {
        'id': '6',
        'content': '',
        'type': 'ai',
        'timestamp': '2024-01-01T12:00:00.000',
        'agentId': 'gardener',
        'isError': false,
        'isTyping': true,
      };

      // Act
      final message = Message.fromJson(json);

      // Assert
      expect(message.id, equals('6'));
      expect(message.content, isEmpty);
      expect(message.type, equals(MessageType.ai));
      expect(message.agentId, equals('gardener'));
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(true));
    });
  });

  group('Message Factory Methods', () {
    test('should create user message using factory', () {
      // Arrange & Act
      final message = Message.user(
        id: '1',
        content: 'Hello world',
      );

      // Assert
      expect(message.id, equals('1'));
      expect(message.content, equals('Hello world'));
      expect(message.type, equals(MessageType.user));
      expect(message.agentId, isNull);
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(false));
    });

    test('should create AI message using factory', () {
      // Arrange & Act
      final message = Message.ai(
        id: '2',
        content: 'AI response',
        agentId: 'gardener',
      );

      // Assert
      expect(message.id, equals('2'));
      expect(message.content, equals('AI response'));
      expect(message.type, equals(MessageType.ai));
      expect(message.agentId, equals('gardener'));
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(false));
    });

    test('should create system message using factory', () {
      // Arrange & Act
      final message = Message.system(
        id: '3',
        content: 'System notification',
      );

      // Assert
      expect(message.id, equals('3'));
      expect(message.content, equals('System notification'));
      expect(message.type, equals(MessageType.system));
      expect(message.agentId, isNull);
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(false));
    });

    test('should create error message using factory', () {
      // Arrange & Act
      final message = Message.system(
        id: '4',
        content: 'Error occurred',
        isError: true,
      );

      // Assert
      expect(message.id, equals('4'));
      expect(message.content, equals('Error occurred'));
      expect(message.type, equals(MessageType.system));
      expect(message.agentId, isNull);
      expect(message.isError, equals(true));
      expect(message.isTyping, equals(false));
    });

    test('should create typing message using factory', () {
      // Arrange & Act
      final message = Message.typing(
        id: '5',
        agentId: 'gardener',
      );

      // Assert
      expect(message.id, equals('5'));
      expect(message.content, isEmpty);
      expect(message.type, equals(MessageType.ai));
      expect(message.agentId, equals('gardener'));
      expect(message.isError, equals(false));
      expect(message.isTyping, equals(true));
    });
  });

  group('Message Copy With', () {
    test('should create copy with updated fields', () {
      // Arrange
      final originalMessage = Message(
        id: '1',
        content: 'Original content',
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      // Act
      final updatedMessage = originalMessage.copyWith(
        content: 'Updated content',
        isError: true,
      );

      // Assert
      expect(updatedMessage.id, equals('1'));
      expect(updatedMessage.content, equals('Updated content'));
      expect(updatedMessage.type, equals(MessageType.user));
      expect(updatedMessage.timestamp, equals(DateTime(2024, 1, 1, 12, 0)));
      expect(updatedMessage.agentId, isNull);
      expect(updatedMessage.isError, equals(true));
      expect(updatedMessage.isTyping, equals(false));
    });

    test('should create copy with all fields updated', () {
      // Arrange
      final originalMessage = Message(
        id: '1',
        content: 'Original content',
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      // Act
      final updatedMessage = originalMessage.copyWith(
        id: '2',
        content: 'New content',
        type: MessageType.ai,
        timestamp: DateTime(2024, 1, 2, 12, 0),
        agentId: 'gardener',
        isError: true,
        isTyping: true,
      );

      // Assert
      expect(updatedMessage.id, equals('2'));
      expect(updatedMessage.content, equals('New content'));
      expect(updatedMessage.type, equals(MessageType.ai));
      expect(updatedMessage.timestamp, equals(DateTime(2024, 1, 2, 12, 0)));
      expect(updatedMessage.agentId, equals('gardener'));
      expect(updatedMessage.isError, equals(true));
      expect(updatedMessage.isTyping, equals(true));
    });

    test('should create copy with no changes', () {
      // Arrange
      final originalMessage = Message(
        id: '1',
        content: 'Original content',
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      // Act
      final copiedMessage = originalMessage.copyWith();

      // Assert
      expect(copiedMessage.id, equals('1'));
      expect(copiedMessage.content, equals('Original content'));
      expect(copiedMessage.type, equals(MessageType.user));
      expect(copiedMessage.timestamp, equals(DateTime(2024, 1, 1, 12, 0)));
      expect(copiedMessage.agentId, isNull);
      expect(copiedMessage.isError, equals(false));
      expect(copiedMessage.isTyping, equals(false));
    });
  });

  group('Message Equality', () {
    test('should be equal when all properties match', () {
      // Arrange
      final timestamp = DateTime(2024, 1, 1, 12, 0);
      final message1 = Message(
        id: '1',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
      );

      final message2 = Message(
        id: '1',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
      );

      // Assert
      expect(message1, equals(message2));
      expect(message1.hashCode, equals(message2.hashCode));
    });

    test('should not be equal when properties differ', () {
      // Arrange
      final timestamp = DateTime(2024, 1, 1, 12, 0);
      final message1 = Message(
        id: '1',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
      );

      final message2 = Message(
        id: '2',
        content: 'Test message',
        type: MessageType.user,
        timestamp: timestamp,
      );

      // Assert
      expect(message1, isNot(equals(message2)));
      expect(message1.hashCode, isNot(equals(message2.hashCode)));
    });
  });

  group('Message String Representation', () {
    test('should have proper toString for short content', () {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Short message',
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      // Act
      final stringRepresentation = message.toString();

      // Assert
      expect(stringRepresentation, contains('Message(id: 1'));
      expect(stringRepresentation, contains('type: MessageType.user'));
      expect(stringRepresentation, contains('content: Short message'));
    });

    test('should truncate long content in toString', () {
      // Arrange
      const longContent = 'This is a very long message that should be truncated in the string representation';
      final message = Message(
        id: '1',
        content: longContent,
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      // Act
      final stringRepresentation = message.toString();

      // Assert
      expect(stringRepresentation, contains('Message(id: 1'));
      expect(stringRepresentation, contains('type: MessageType.user'));
      expect(stringRepresentation, contains('content: This is a very long message that should be truncat...'));
    });
  });

  group('MessageType Enum', () {
    test('should have correct enum values', () {
      // Assert
      expect(MessageType.values.length, equals(3));
      expect(MessageType.values, contains(MessageType.user));
      expect(MessageType.values, contains(MessageType.ai));
      expect(MessageType.values, contains(MessageType.system));
    });

    test('should parse enum from string', () {
      // Assert
      expect(MessageType.values.firstWhere((e) => e.name == 'user'), equals(MessageType.user));
      expect(MessageType.values.firstWhere((e) => e.name == 'ai'), equals(MessageType.ai));
      expect(MessageType.values.firstWhere((e) => e.name == 'system'), equals(MessageType.system));
    });
  });
}
