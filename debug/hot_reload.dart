/// Hot reload script
/// 
/// This script triggers hot reload by making a small change to a file
/// and then reverting it, which forces Flutter to reload the changes.
library;

import 'dart:io';

void main() async {
  print('🔄 Triggering hot reload...');
  
  // Read the current message_bubble.dart file
  final file = File('lib/features/chat/presentation/widgets/message_bubble.dart');
  final content = await file.readAsString();
  
  // Add a small comment to trigger hot reload
  final modifiedContent = content.replaceFirst(
    '/// Full-screen image viewer with navigation',
    '/// Full-screen image viewer with navigation // Hot reload trigger',
  );
  
  // Write the modified content
  await file.writeAsString(modifiedContent);
  
  // Wait a moment for Flutter to detect the change
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Revert the change
  await file.writeAsString(content);
  
  print('✅ Hot reload triggered successfully!');
  print('📱 Check http://localhost:8089 for changes');
}

