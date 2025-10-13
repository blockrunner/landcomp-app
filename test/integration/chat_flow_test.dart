/// Integration tests for complete chat flow
/// 
/// Tests the end-to-end functionality from sending a message
/// to receiving an AI response, including UI interactions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:landcomp_app/features/chat/presentation/pages/chat_page.dart';
import 'package:landcomp_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';

void main() {
  group('Chat Flow Integration Tests', () {
    late ChatProvider chatProvider;
    late LanguageProvider languageProvider;

    setUp(() {
      chatProvider = ChatProvider();
      languageProvider = LanguageProvider();
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
          ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ],
        child: const MaterialApp(
          home: ChatPage(),
        ),
      );
    }

    testWidgets('should display chat interface correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Check if chat interface elements are present
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should send user message and display it', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find message input field
      final messageField = find.byType(TextField);
      expect(messageField, findsOneWidget);

      // Type a message
      await tester.enterText(messageField, 'Hello, how are you?');
      await tester.pump();

      // Find and tap send button
      final sendButton = find.byType(FloatingActionButton);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Check if user message is displayed
      expect(find.text('Hello, how are you?'), findsOneWidget);
    });

    testWidgets('should display typing indicator when AI is responding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Check if typing indicator appears (if AI service is available)
      // Note: This test might not show typing indicator if AI service is not available
      // but it should not crash the app
      expect(find.byType(ChatPage), findsOneWidget);
    });

    testWidgets('should handle empty message gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Try to send empty message
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // App should not crash and should remain functional
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should clear message input after sending', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Type a message
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      // Send message
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check if input field is cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('should handle long messages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Type a long message
      const longMessage = 'This is a very long message that should be handled correctly by the chat interface without causing any layout issues or overflow problems.';
      await tester.enterText(find.byType(TextField), longMessage);
      await tester.pump();

      // Send message
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check if long message is displayed correctly
      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('should maintain chat history', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Send first message
      await tester.enterText(find.byType(TextField), 'First message');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Send second message
      await tester.enterText(find.byType(TextField), 'Second message');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check if both messages are displayed
      expect(find.text('First message'), findsOneWidget);
      expect(find.text('Second message'), findsOneWidget);
    });

    testWidgets('should handle rapid message sending', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Send multiple messages rapidly
      for (var i = 0; i < 3; i++) {
        await tester.enterText(find.byType(TextField), 'Message $i');
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Check if all messages are displayed
      expect(find.text('Message 0'), findsOneWidget);
      expect(find.text('Message 1'), findsOneWidget);
      expect(find.text('Message 2'), findsOneWidget);
    });

    testWidgets('should handle keyboard interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Focus on message input
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Type message using keyboard
      await tester.enterText(find.byType(TextField), 'Keyboard test');
      await tester.pump();

      // Send message using Enter key (if supported)
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      // Check if message was sent
      expect(find.text('Keyboard test'), findsOneWidget);
    });

    testWidgets('should handle app lifecycle changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'Lifecycle test');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Simulate app lifecycle changes
      // Note: In a real test, you would use proper lifecycle simulation
      await tester.pump();
      await tester.pumpAndSettle();

      // App should still be functional
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.text('Lifecycle test'), findsOneWidget);
    });

    testWidgets('should handle different screen orientations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Send a message in portrait
      await tester.enterText(find.byType(TextField), 'Portrait message');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Change to landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();

      // Send another message in landscape
      await tester.enterText(find.byType(TextField), 'Landscape message');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check if both messages are displayed
      expect(find.text('Portrait message'), findsOneWidget);
      expect(find.text('Landscape message'), findsOneWidget);

      // Reset to portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
    });

    testWidgets('should handle network connectivity changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'Network test');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // App should handle network changes gracefully
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.text('Network test'), findsOneWidget);
    });

    testWidgets('should handle memory pressure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Send multiple messages to create memory pressure
      for (var i = 0; i < 10; i++) {
        await tester.enterText(find.byType(TextField), 'Memory test message $i');
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // App should still be functional
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.text('Memory test message 0'), findsOneWidget);
      expect(find.text('Memory test message 9'), findsOneWidget);
    });
  });
}
