/// Migration helper for converting existing chat sessions to projects
/// 
/// This helper handles the migration from single-session chat to
/// multi-project system by converting existing ChatSession data to Project data.
library;

import '../../features/chat/domain/entities/chat_session.dart';
import '../../features/projects/domain/entities/project.dart';
import 'chat_storage.dart';

/// Migration helper for data migration
class MigrationHelper {
  MigrationHelper._();
  
  static final MigrationHelper _instance = MigrationHelper._();
  static MigrationHelper get instance => _instance;
  
  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      final chatStorage = ChatStorage.instance;
      await chatStorage.initialize();
      
      // Check if there are existing chat sessions but no projects
      final sessions = await chatStorage.loadAllSessions();
      final projects = await chatStorage.loadAllProjects();
      
      return sessions.isNotEmpty && projects.isEmpty;
    } catch (e) {
      print('❌ Error checking migration status: $e');
      return false;
    }
  }
  
  /// Perform migration from chat sessions to projects
  Future<bool> performMigration() async {
    try {
      print('🔄 Starting migration from chat sessions to projects...');
      
      final chatStorage = ChatStorage.instance;
      await chatStorage.initialize();
      
      // Load existing sessions
      final sessions = await chatStorage.loadAllSessions();
      
      if (sessions.isEmpty) {
        print('✅ No sessions to migrate');
        return true;
      }
      
      print('📂 Found ${sessions.length} sessions to migrate');
      
      // Convert each session to a project
      for (final session in sessions) {
        try {
          final project = _convertSessionToProject(session);
          await chatStorage.saveProject(project);
          print('✅ Migrated session: ${session.id} -> ${project.title}');
        } catch (e) {
          print('❌ Error migrating session ${session.id}: $e');
          // Continue with other sessions
        }
      }
      
      print('✅ Migration completed successfully');
      return true;
    } catch (e) {
      print('❌ Error during migration: $e');
      return false;
    }
  }
  
  /// Convert a ChatSession to a Project
  Project _convertSessionToProject(ChatSession session) {
    // Generate title from first user message or use default
    String title = session.title;
    String? previewText;
    
    final firstUserMessage = session.messages
        .where((m) => m.type.toString().contains('user'))
        .firstOrNull;
    
    if (firstUserMessage != null) {
      previewText = firstUserMessage.content.length > 50 
          ? '${firstUserMessage.content.substring(0, 50)}...'
          : firstUserMessage.content;
      
      // Auto-generate title from first message if using default
      if (title == 'AI Assistant' || title.isEmpty) {
        title = firstUserMessage.content.length > 50 
            ? '${firstUserMessage.content.substring(0, 50)}...'
            : firstUserMessage.content;
      }
    }
    
    // If still no good title, use a generic one
    if (title.isEmpty || title == 'AI Assistant') {
      title = 'Migrated Project';
    }
    
    return Project(
      id: session.id,
      title: title,
      // agentId: session.agentId,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      messages: session.messages,
      previewText: previewText,
      isFavorite: false,
    );
  }
  
  /// Clean up old session data after successful migration
  Future<void> cleanupOldSessions() async {
    try {
      print('🧹 Cleaning up old session data...');
      
      final chatStorage = ChatStorage.instance;
      await chatStorage.initialize();
      
      // Clear all old sessions
      await chatStorage.clearAllSessions();
      
      print('✅ Old session data cleaned up');
    } catch (e) {
      print('❌ Error cleaning up old sessions: $e');
    }
  }
  
  /// Perform complete migration with cleanup
  Future<bool> performCompleteMigration() async {
    try {
      // Check if migration is needed
      if (!await isMigrationNeeded()) {
        print('✅ No migration needed');
        return true;
      }
      
      // Perform migration
      final success = await performMigration();
      
      if (success) {
        // Clean up old data
        await cleanupOldSessions();
        print('✅ Complete migration finished successfully');
      }
      
      return success;
    } catch (e) {
      print('❌ Error during complete migration: $e');
      return false;
    }
  }
  
  /// Get migration statistics
  Future<Map<String, dynamic>> getMigrationStats() async {
    try {
      final chatStorage = ChatStorage.instance;
      await chatStorage.initialize();
      
      final sessions = await chatStorage.loadAllSessions();
      final projects = await chatStorage.loadAllProjects();
      
      return {
        'sessions_count': sessions.length,
        'projects_count': projects.length,
        'migration_needed': sessions.isNotEmpty && projects.isEmpty,
        'migration_completed': sessions.isEmpty && projects.isNotEmpty,
      };
    } catch (e) {
      print('❌ Error getting migration stats: $e');
      return {
        'sessions_count': 0,
        'projects_count': 0,
        'migration_needed': false,
        'migration_completed': false,
      };
    }
  }
}
