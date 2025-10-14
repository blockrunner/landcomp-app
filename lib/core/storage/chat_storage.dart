/// Chat storage service for persisting chat history
///
/// This service handles saving and loading chat sessions
/// using Hive for local storage.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:landcomp_app/core/constants/app_constants.dart';
import 'package:landcomp_app/core/utils/json_utils.dart';
import 'package:landcomp_app/features/chat/domain/entities/chat_session.dart';
import 'package:landcomp_app/features/projects/domain/entities/project.dart';

/// Chat storage service
class ChatStorage {
  ChatStorage._();

  static final ChatStorage _instance = ChatStorage._();
  
  /// Singleton instance of the ChatStorage
  static ChatStorage get instance => _instance;

  late Box<String> _chatBox;
  late Box<String> _projectsBox;
  bool _isInitialized = false;

  /// Initialize the storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _chatBox = await Hive.openBox<String>(AppConstants.chatHistoryBox);
      _projectsBox = await Hive.openBox<String>('projects');
      _isInitialized = true;
      debugPrint('✅ ChatStorage initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing ChatStorage: $e');
      rethrow;
    }
  }

  /// Save a chat session
  Future<void> saveSession(ChatSession session) async {
    if (!_isInitialized) await initialize();

    try {
      // Validate session data before saving
      if (!_validateSession(session)) {
        throw Exception('Session validation failed');
      }

      // Debug: Check for images in messages
      var totalImages = 0;
      var totalImageSize = 0;
      for (final message in session.messages) {
        if (message.attachments != null && message.attachments!.isNotEmpty) {
          final imageAttachments = message.attachments!
              .where((a) => a.isImage)
              .toList();
          totalImages += imageAttachments.length;
          totalImageSize += imageAttachments
              .map((img) => img.size)
              .reduce((a, b) => a + b)
              ;
        }
      }

      if (totalImages > 0) {
        debugPrint(
          '💾 Saving session with $totalImages images, '
          'total size: ${(totalImageSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );

        // Check if total size is too large (> 10MB)
        if (totalImageSize > 10 * 1024 * 1024) {
          debugPrint(
            '⚠️ Warning: Session size is very large '
            '(${(totalImageSize / 1024 / 1024).toStringAsFixed(2)} MB)',
          );
        }
      }

      // Optimize JSON data
      final sessionData = session.toJson();
      final optimizedData = JsonUtils.optimizeImageData(sessionData);
      final sessionJson = JsonUtils.compressJson(optimizedData);

      final originalSize = JsonUtils.calculateJsonSize(sessionData);
      final compressedSize = sessionJson.length * 2; // UTF-16 encoding
      final compressionRatio = JsonUtils.calculateCompressionRatio(
        originalSize,
        compressedSize,
      );

      debugPrint(
        '💾 JSON size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );
      debugPrint('💾 Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');

      // Check JSON size limit (50MB)
      if (compressedSize > 50 * 1024 * 1024) {
        throw Exception(
          'Session JSON too large: '
          '${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );
      }

      await _chatBox.put(session.id, sessionJson);
      debugPrint('💾 Saved session: ${session.id}');
    } catch (e) {
      debugPrint('❌ Error saving session: $e');
      rethrow;
    }
  }

  /// Load all chat sessions
  Future<List<ChatSession>> loadAllSessions() async {
    if (!_isInitialized) await initialize();

    try {
      final sessions = <ChatSession>[];

      for (final key in _chatBox.keys) {
        final sessionJson = _chatBox.get(key);
        if (sessionJson != null) {
          final rawSessionData =
              jsonDecode(sessionJson) as Map<String, dynamic>;
          final sessionData = JsonUtils.restoreImageData(rawSessionData);

          // Debug: Check raw JSON data for images
          final messages = sessionData['messages'] as List<dynamic>?;
          if (messages != null) {
            for (final messageData in messages) {
              final messageJson = messageData as Map<String, dynamic>;
              final imageBytes = messageJson['imageBytes'];
              if (imageBytes != null) {
                debugPrint(
                  '📂 Raw JSON has imageBytes for message '
                  '${messageJson['id']}: ${(imageBytes as List).length} images',
                );
              }
            }
          }

          final session = ChatSession.fromJson(sessionData);

          // Validate loaded session
          if (!_validateSession(session)) {
            debugPrint('❌ Skipping invalid session: ${session.id}');
            continue;
          }

          // Debug: Check for images in loaded session
          var totalImages = 0;
          for (final message in session.messages) {
            if (message.attachments != null &&
                message.attachments!.isNotEmpty) {
              final imageAttachments = message.attachments!
                  .where((a) => a.isImage)
                  .toList();
              totalImages += imageAttachments.length;
            }
          }

          if (totalImages > 0) {
            debugPrint('📂 Loaded session ${session.id} with $totalImages images');
          } else {
            debugPrint('📂 Loaded session ${session.id} with NO images');
          }

          sessions.add(session);
        }
      }

      // Sort by updatedAt descending (newest first)
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      debugPrint('📂 Loaded ${sessions.length} chat sessions');
      return sessions;
    } catch (e) {
      debugPrint('❌ Error loading sessions: $e');
      return [];
    }
  }

  /// Load a specific session by ID
  Future<ChatSession?> loadSession(String sessionId) async {
    if (!_isInitialized) await initialize();

    try {
      final sessionJson = _chatBox.get(sessionId);
      if (sessionJson != null) {
        final rawSessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
        final sessionData = JsonUtils.restoreImageData(rawSessionData);
        return ChatSession.fromJson(sessionData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading session $sessionId: $e');
      return null;
    }
  }

  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    if (!_isInitialized) await initialize();

    try {
      await _chatBox.delete(sessionId);
      debugPrint('🗑️ Deleted session: $sessionId');
    } catch (e) {
      debugPrint('❌ Error deleting session: $e');
      rethrow;
    }
  }

  /// Clear all chat history
  Future<void> clearAllSessions() async {
    if (!_isInitialized) await initialize();

    try {
      await _chatBox.clear();
      debugPrint('🧹 Cleared all chat sessions');
    } catch (e) {
      debugPrint('❌ Error clearing sessions: $e');
      rethrow;
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    if (!_isInitialized) await initialize();

    try {
      final totalSessions = _chatBox.length;
      final totalMessages = await _getTotalMessageCount();

      return {
        'total_sessions': totalSessions,
        'total_messages': totalMessages,
        'storage_size_bytes': await _getStorageSize(),
      };
    } catch (e) {
      debugPrint('❌ Error getting storage stats: $e');
      return {
        'total_sessions': 0,
        'total_messages': 0,
        'storage_size_bytes': 0,
      };
    }
  }

  /// Get total message count across all sessions
  Future<int> _getTotalMessageCount() async {
    var totalMessages = 0;

    for (final key in _chatBox.keys) {
      final sessionJson = _chatBox.get(key);
      if (sessionJson != null) {
        try {
          final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
          final messages = sessionData['messages'] as List<dynamic>?;
          if (messages != null) {
            totalMessages += messages.length;
          }
        } catch (e) {
          // Skip corrupted sessions
          continue;
        }
      }
    }

    return totalMessages;
  }

  /// Get approximate storage size in bytes
  Future<int> _getStorageSize() async {
    var totalSize = 0;

    for (final key in _chatBox.keys) {
      final sessionJson = _chatBox.get(key);
      if (sessionJson != null) {
        totalSize += sessionJson.length * 2; // Approximate UTF-16 size
      }
    }

    return totalSize;
  }

  /// Validate session data integrity
  bool _validateSession(ChatSession session) {
    try {
      // Check session ID
      if (session.id.isEmpty) {
        debugPrint('❌ Session validation failed: Empty session ID');
        return false;
      }

      // Check messages
      for (final message in session.messages) {
        // Check message ID
        if (message.id.isEmpty) {
          debugPrint('❌ Session validation failed: Empty message ID');
          return false;
        }

        // Check message content (allow empty content for typing messages)
        if (message.content.isEmpty &&
            (message.attachments == null || message.attachments!.isEmpty) &&
            !message.isTyping) {
          debugPrint(
            '❌ Session validation failed: '
            'Empty message content and no images',
          );
          return false;
        }

        // Check attachment data integrity
        if (message.attachments != null && message.attachments!.isNotEmpty) {
          for (var i = 0; i < message.attachments!.length; i++) {
            final attachment = message.attachments![i];
            if (attachment.data == null || attachment.data!.isEmpty) {
              debugPrint(
                '❌ Session validation failed: '
                'Empty attachment data at index $i',
              );
              return false;
            }

            // Check attachment size
            if (attachment.size > 10 * 1024 * 1024) {
              // 10MB limit per attachment
              debugPrint(
                '❌ Session validation failed: '
                'Attachment too large at index $i: ${attachment.size} bytes',
              );
              return false;
            }
          }
        }
      }

      debugPrint('✅ Session validation passed: ${session.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Session validation error: $e');
      return false;
    }
  }

  // ========== PROJECT METHODS ==========

  /// Save a project
  Future<void> saveProject(Project project) async {
    if (!_isInitialized) await initialize();

    try {
      // Validate project data before saving
      if (!_validateProject(project)) {
        throw Exception('Project validation failed');
      }

      // Debug: Check for images in messages
      var totalImages = 0;
      var totalImageSize = 0;
      for (final message in project.messages) {
        if (message.attachments != null && message.attachments!.isNotEmpty) {
          final imageAttachments = message.attachments!
              .where((a) => a.isImage)
              .toList();
          totalImages += imageAttachments.length;
          totalImageSize += imageAttachments
              .map((img) => img.size)
              .reduce((a, b) => a + b)
              ;
        }
      }

      if (totalImages > 0) {
        debugPrint(
          '💾 Saving project with $totalImages images, '
          'total size: ${(totalImageSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );

        // Check if total size is too large (> 10MB)
        if (totalImageSize > 10 * 1024 * 1024) {
          debugPrint(
            '⚠️ Warning: Project size is very large '
            '(${(totalImageSize / 1024 / 1024).toStringAsFixed(2)} MB)',
          );
        }
      }

      // Optimize JSON data
      final projectData = project.toJson();
      final optimizedData = JsonUtils.optimizeImageData(projectData);
      final projectJson = JsonUtils.compressJson(optimizedData);

      final originalSize = JsonUtils.calculateJsonSize(projectData);
      final compressedSize = projectJson.length * 2; // UTF-16 encoding
      final compressionRatio = JsonUtils.calculateCompressionRatio(
        originalSize,
        compressedSize,
      );

      debugPrint(
        '💾 JSON size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );
      debugPrint('💾 Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');

      // Check JSON size limit (50MB)
      if (compressedSize > 50 * 1024 * 1024) {
        throw Exception(
          'Project JSON too large: '
          '${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );
      }

      await _projectsBox.put(project.id, projectJson);
      debugPrint('💾 Saved project: ${project.id}');
    } catch (e) {
      debugPrint('❌ Error saving project: $e');
      rethrow;
    }
  }

  /// Load all projects
  Future<List<Project>> loadAllProjects() async {
    if (!_isInitialized) await initialize();

    try {
      final projects = <Project>[];

      for (final key in _projectsBox.keys) {
        final projectJson = _projectsBox.get(key);
        if (projectJson != null) {
          final rawProjectData =
              jsonDecode(projectJson) as Map<String, dynamic>;
          final projectData = JsonUtils.restoreImageData(rawProjectData);

          // Debug: Check raw JSON data for images
          final messages = projectData['messages'] as List<dynamic>?;
          if (messages != null) {
            for (final messageData in messages) {
              final messageJson = messageData as Map<String, dynamic>;
              final imageBytes = messageJson['imageBytes'];
              if (imageBytes != null) {
                debugPrint(
                  '📂 Raw JSON has imageBytes for message '
                  '${messageJson['id']}: ${(imageBytes as List).length} images',
                );
              }
            }
          }

          final project = Project.fromJson(projectData);

          // Validate loaded project
          if (!_validateProject(project)) {
            debugPrint('❌ Skipping invalid project: ${project.id}');
            continue;
          }

          // Debug: Check for images in loaded project
          var totalImages = 0;
          for (final message in project.messages) {
            if (message.attachments != null &&
                message.attachments!.isNotEmpty) {
              final imageAttachments = message.attachments!
                  .where((a) => a.isImage)
                  .toList();
              totalImages += imageAttachments.length;
            }
          }

          if (totalImages > 0) {
            debugPrint('📂 Loaded project ${project.id} with $totalImages images');
          } else {
            debugPrint('📂 Loaded project ${project.id} with NO images');
          }

          projects.add(project);
        }
      }

      // Sort by updatedAt descending (newest first)
      projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      debugPrint('📂 Loaded ${projects.length} projects');
      return projects;
    } catch (e) {
      debugPrint('❌ Error loading projects: $e');
      return [];
    }
  }

  /// Load a specific project by ID
  Future<Project?> loadProject(String projectId) async {
    if (!_isInitialized) await initialize();

    try {
      final projectJson = _projectsBox.get(projectId);
      if (projectJson != null) {
        final rawProjectData = jsonDecode(projectJson) as Map<String, dynamic>;
        final projectData = JsonUtils.restoreImageData(rawProjectData);
        return Project.fromJson(projectData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading project $projectId: $e');
      return null;
    }
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    if (!_isInitialized) await initialize();

    try {
      await _projectsBox.delete(projectId);
      debugPrint('🗑️ Deleted project: $projectId');
    } catch (e) {
      debugPrint('❌ Error deleting project: $e');
      rethrow;
    }
  }

  /// Update project title
  Future<void> updateProjectTitle(String projectId, String newTitle) async {
    if (!_isInitialized) await initialize();

    try {
      final project = await loadProject(projectId);
      if (project != null) {
        final updatedProject = project.updateTitle(newTitle);
        await saveProject(updatedProject);
        debugPrint('📝 Updated project title: $projectId -> $newTitle');
      } else {
        throw Exception('Project not found: $projectId');
      }
    } catch (e) {
      debugPrint('❌ Error updating project title: $e');
      rethrow;
    }
  }

  /// Clear all projects
  Future<void> clearAllProjects() async {
    if (!_isInitialized) await initialize();

    try {
      await _projectsBox.clear();
      debugPrint('🧹 Cleared all projects');
    } catch (e) {
      debugPrint('❌ Error clearing projects: $e');
      rethrow;
    }
  }

  /// Get project storage statistics
  Future<Map<String, dynamic>> getProjectStorageStats() async {
    if (!_isInitialized) await initialize();

    try {
      final totalProjects = _projectsBox.length;
      final totalMessages = await _getTotalProjectMessageCount();

      return {
        'total_projects': totalProjects,
        'total_messages': totalMessages,
        'storage_size_bytes': await _getProjectStorageSize(),
      };
    } catch (e) {
      debugPrint('❌ Error getting project storage stats: $e');
      return {
        'total_projects': 0,
        'total_messages': 0,
        'storage_size_bytes': 0,
      };
    }
  }

  /// Get total message count across all projects
  Future<int> _getTotalProjectMessageCount() async {
    var totalMessages = 0;

    for (final key in _projectsBox.keys) {
      final projectJson = _projectsBox.get(key);
      if (projectJson != null) {
        try {
          final projectData = jsonDecode(projectJson) as Map<String, dynamic>;
          final messages = projectData['messages'] as List<dynamic>?;
          if (messages != null) {
            totalMessages += messages.length;
          }
        } catch (e) {
          // Skip corrupted projects
          continue;
        }
      }
    }

    return totalMessages;
  }

  /// Get approximate project storage size in bytes
  Future<int> _getProjectStorageSize() async {
    var totalSize = 0;

    for (final key in _projectsBox.keys) {
      final projectJson = _projectsBox.get(key);
      if (projectJson != null) {
        totalSize += projectJson.length * 2; // Approximate UTF-16 size
      }
    }

    return totalSize;
  }

  /// Validate project data integrity
  bool _validateProject(Project project) {
    try {
      // Check project ID
      if (project.id.isEmpty) {
        debugPrint('❌ Project validation failed: Empty project ID');
        return false;
      }

      // Check project title
      if (project.title.isEmpty) {
        debugPrint('❌ Project validation failed: Empty project title');
        return false;
      }

      // Check messages
      for (final message in project.messages) {
        // Check message ID
        if (message.id.isEmpty) {
          debugPrint('❌ Project validation failed: Empty message ID');
          return false;
        }

        // Check message content
        if (message.content.isEmpty &&
            (message.attachments == null || message.attachments!.isEmpty)) {
          debugPrint(
            '❌ Project validation failed: '
            'Empty message content and no images',
          );
          return false;
        }

        // Check attachment data integrity
        if (message.attachments != null && message.attachments!.isNotEmpty) {
          for (var i = 0; i < message.attachments!.length; i++) {
            final attachment = message.attachments![i];
            if (attachment.data == null || attachment.data!.isEmpty) {
              debugPrint(
                '❌ Project validation failed: '
                'Empty attachment data at index $i',
              );
              return false;
            }

            // Check attachment size
            if (attachment.size > 10 * 1024 * 1024) {
              // 10MB limit per attachment
              debugPrint(
                '❌ Project validation failed: '
                'Attachment too large at index $i: ${attachment.size} bytes',
              );
              return false;
            }
          }
        }
      }

      debugPrint('✅ Project validation passed: ${project.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Project validation error: $e');
      return false;
    }
  }

  /// Get context metadata for a session
  Future<Map<String, dynamic>?> getContextMetadata(String sessionId) async {
    if (!_isInitialized) await initialize();

    try {
      final key = 'context_metadata_$sessionId';
      final metadataJson = _chatBox.get(key);

      if (metadataJson != null) {
        final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
        debugPrint('📊 Retrieved context metadata for session: $sessionId');
        return metadata;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting context metadata: $e');
      return null;
    }
  }

  /// Save context metadata for a session
  Future<void> saveContextMetadata(
    String sessionId,
    Map<String, dynamic> metadata,
  ) async {
    if (!_isInitialized) await initialize();

    try {
      final key = 'context_metadata_$sessionId';
      final metadataJson = jsonEncode(metadata);

      await _chatBox.put(key, metadataJson);
      debugPrint('💾 Saved context metadata for session: $sessionId');
    } catch (e) {
      debugPrint('❌ Error saving context metadata: $e');
      rethrow;
    }
  }

  /// Clear context metadata for a session
  Future<void> clearContextMetadata(String sessionId) async {
    if (!_isInitialized) await initialize();

    try {
      final key = 'context_metadata_$sessionId';
      await _chatBox.delete(key);
      debugPrint('🗑️ Cleared context metadata for session: $sessionId');
    } catch (e) {
      debugPrint('❌ Error clearing context metadata: $e');
      rethrow;
    }
  }

  /// Get all context metadata keys
  Future<List<String>> getAllContextMetadataKeys() async {
    if (!_isInitialized) await initialize();

    try {
      final keys = _chatBox.keys
          .where((key) => key.toString().startsWith('context_metadata_'))
          .map((key) => key.toString().substring('context_metadata_'.length))
          .toList();

      return keys;
    } catch (e) {
      debugPrint('❌ Error getting context metadata keys: $e');
      return [];
    }
  }

  /// Clean up old context metadata (older than specified days)
  Future<void> cleanupOldContextMetadata({int daysOld = 30}) async {
    if (!_isInitialized) await initialize();

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final keysToDelete = <String>[];

      for (final key in _chatBox.keys) {
        if (key.toString().startsWith('context_metadata_')) {
          final metadataJson = _chatBox.get(key);
          if (metadataJson != null) {
            try {
              final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
              final timestamp = DateTime.parse(metadata['timestamp'] as String);

              if (timestamp.isBefore(cutoffDate)) {
                keysToDelete.add(key.toString());
              }
            } catch (e) {
              // If we can't parse the metadata, delete it
              keysToDelete.add(key.toString());
            }
          }
        }
      }

      for (final key in keysToDelete) {
        await _chatBox.delete(key);
      }

      if (keysToDelete.isNotEmpty) {
        debugPrint(
          '🧹 Cleaned up ${keysToDelete.length} old context metadata entries',
        );
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up context metadata: $e');
    }
  }

  /// Close the storage
  Future<void> close() async {
    if (_isInitialized) {
      await _chatBox.close();
      await _projectsBox.close();
      _isInitialized = false;
      debugPrint('🔒 ChatStorage closed');
    }
  }
}
