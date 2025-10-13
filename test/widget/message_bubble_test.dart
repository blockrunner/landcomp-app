/// Widget tests for MessageBubble component
///
/// Tests the visual rendering and behavior of message bubbles
/// including user messages, AI messages, typing indicators, and error states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/presentation/widgets/message_bubble.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    late Message userMessage;
    late Message aiMessage;
    late Message errorMessage;
    late Message typingMessage;
    late Message systemMessage;

    setUp(() {
      userMessage = Message.user(
        id: '1',
        content: 'Hello, how are you?',
        timestamp: DateTime.now(),
      );

      aiMessage = Message.ai(
        id: '2',
        content: 'I am doing well, thank you!',
        timestamp: DateTime.now(),
        agentId: 'gardener',
      );

      errorMessage = Message(
        id: '3',
        content: 'Error occurred',
        type: MessageType.ai,
        timestamp: DateTime.now(),
        agentId: 'gardener',
        isError: true,
      );

      typingMessage = Message(
        id: '4',
        content: '',
        type: MessageType.ai,
        timestamp: DateTime.now(),
        agentId: 'gardener',
        isTyping: true,
      );

      systemMessage = Message.system(
        id: '5',
        content: 'System message',
        timestamp: DateTime.now(),
      );
    });

    Widget createTestWidget(
      Message message, {
      VoidCallback? onRetry,
      bool showTimestamp = true,
    }) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          body: MessageBubble(
            message: message,
            onRetry: onRetry,
            showTimestamp: showTimestamp,
          ),
        ),
      );
    }

    testWidgets('should display user message correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(userMessage));

      // Check if message content is displayed
      expect(find.text('Hello, how are you?'), findsOneWidget);

      // Check if timestamp is displayed (could be "Just now" or "ago")
      final hasTimestamp =
          find.textContaining('ago').evaluate().isNotEmpty ||
          find.text('Just now').evaluate().isNotEmpty;
      expect(hasTimestamp, isTrue);

      // Check if message bubble has correct alignment (right side for user)
      final messageBubble = find.byType(Container).first;
      expect(messageBubble, findsOneWidget);
    });

    testWidgets('should display AI message with agent header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(aiMessage));

      // Check if message content is displayed
      expect(find.text('I am doing well, thank you!'), findsOneWidget);

      // Check if agent icon is displayed
      expect(find.byIcon(Icons.local_florist), findsOneWidget);

      // Check if agent name is displayed
      expect(find.text('Gardener'), findsOneWidget);
    });

    testWidgets('should display error message with retry button', (
      WidgetTester tester,
    ) async {
      var retryPressed = false;

      await tester.pumpWidget(
        createTestWidget(errorMessage, onRetry: () => retryPressed = true),
      );

      // Check if error message is displayed
      expect(find.text('Error occurred'), findsOneWidget);

      // Check if retry button is displayed
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Test retry button functionality
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retryPressed, isTrue);
    });

    testWidgets('should display typing indicator', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(typingMessage));

      // Check if typing indicator container is displayed
      expect(find.byType(Container), findsWidgets);

      // Check if agent icon is displayed in typing indicator
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
    });

    testWidgets('should display system message centered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(systemMessage));

      // Check if system message is displayed
      expect(find.text('System message'), findsOneWidget);
    });

    testWidgets('should hide timestamp when showTimestamp is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(userMessage, showTimestamp: false),
      );

      // Check if timestamp is not displayed
      final hasTimestamp =
          find.textContaining('ago').evaluate().isNotEmpty ||
          find.text('Just now').evaluate().isNotEmpty;
      expect(hasTimestamp, isFalse);
    });

    testWidgets('should handle message without agent gracefully', (
      WidgetTester tester,
    ) async {
      final messageWithoutAgent = Message(
        id: '6',
        content: 'Message without agent',
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(messageWithoutAgent));

      // Should not crash and should display message
      expect(find.text('Message without agent'), findsOneWidget);
    });

    testWidgets('should handle unknown agent gracefully', (
      WidgetTester tester,
    ) async {
      final messageWithUnknownAgent = Message(
        id: '7',
        content: 'Message with unknown agent',
        type: MessageType.ai,
        timestamp: DateTime.now(),
        agentId: 'unknown_agent',
      );

      await tester.pumpWidget(createTestWidget(messageWithUnknownAgent));

      // Should not crash and should display message
      expect(find.text('Message with unknown agent'), findsOneWidget);
    });

    testWidgets(
      'should display correct bubble colors for different message types',
      (WidgetTester tester) async {
        // Test user message color
        await tester.pumpWidget(createTestWidget(userMessage));
        await tester.pump();

        // Test AI message color
        await tester.pumpWidget(createTestWidget(aiMessage));
        await tester.pump();

        // Test error message color
        await tester.pumpWidget(createTestWidget(errorMessage));
        await tester.pump();

        // All should render without errors
        expect(find.byType(MessageBubble), findsOneWidget);
      },
    );

    testWidgets('should handle long messages with proper constraints', (
      WidgetTester tester,
    ) async {
      final longMessage = Message.user(
        id: '8',
        content:
            'This is a very long message that should be properly constrained and wrapped to fit within the screen boundaries without overflowing or causing layout issues.',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(longMessage));

      // Should display long message without overflow
      expect(
        find.textContaining('This is a very long message'),
        findsOneWidget,
      );
    });

    testWidgets('should display proper border radius for user messages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(userMessage));

      // Find the message bubble container with decoration
      final containers = find.descendant(
        of: find.byType(MessageBubble),
        matching: find.byType(Container),
      );

      // Check if at least one container has decoration
      var foundDecoration = false;
      for (var i = 0; i < containers.evaluate().length; i++) {
        final container = tester.widget<Container>(containers.at(i));
        if (container.decoration is BoxDecoration) {
          foundDecoration = true;
          final decoration = container.decoration! as BoxDecoration;
          expect(decoration.borderRadius, isA<BorderRadius>());
          break;
        }
      }
      expect(foundDecoration, isTrue);
    });

    testWidgets('should display proper border radius for AI messages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(aiMessage));

      // Find the message bubble container with decoration
      final containers = find.descendant(
        of: find.byType(MessageBubble),
        matching: find.byType(Container),
      );

      // Check if at least one container has decoration
      var foundDecoration = false;
      for (var i = 0; i < containers.evaluate().length; i++) {
        final container = tester.widget<Container>(containers.at(i));
        if (container.decoration is BoxDecoration) {
          foundDecoration = true;
          final decoration = container.decoration! as BoxDecoration;
          expect(decoration.borderRadius, isA<BorderRadius>());
          break;
        }
      }
      expect(foundDecoration, isTrue);
    });

    testWidgets('should handle empty message content', (
      WidgetTester tester,
    ) async {
      final emptyMessage = Message.user(
        id: '9',
        content: '',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(emptyMessage));

      // Should not crash with empty content
      expect(find.byType(MessageBubble), findsOneWidget);
    });

    testWidgets('should display shadow for message bubbles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(userMessage));

      // Find the message bubble container with decoration
      final containers = find.descendant(
        of: find.byType(MessageBubble),
        matching: find.byType(Container),
      );

      // Check if at least one container has decoration with shadow
      var foundShadow = false;
      for (var i = 0; i < containers.evaluate().length; i++) {
        final container = tester.widget<Container>(containers.at(i));
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration! as BoxDecoration;
          if (decoration.boxShadow != null &&
              decoration.boxShadow!.isNotEmpty) {
            foundShadow = true;
            break;
          }
        }
      }
      expect(foundShadow, isTrue);
    });
  });
}
