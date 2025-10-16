/// Chat page for AI conversation
///
/// This page provides the main chat interface for users to interact
/// with the AI agents for landscape design assistance.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:typed_data';
import 'package:landcomp_app/shared/widgets/logo_widget.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';
import 'package:landcomp_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:landcomp_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:landcomp_app/features/chat/presentation/widgets/image_picker_widget.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/projects/presentation/providers/project_provider.dart';
import 'package:landcomp_app/features/projects/presentation/widgets/projects_sidebar.dart';
import 'package:landcomp_app/features/projects/presentation/widgets/new_project_dialog.dart';
import 'package:landcomp_app/features/projects/presentation/widgets/rename_project_dialog.dart';
import 'package:landcomp_app/features/projects/domain/entities/project.dart';

/// Chat page widget
class ChatPage extends StatefulWidget {
  /// Creates a chat page
  const ChatPage({super.key, this.projectId});

  /// Optional project ID to load specific project
  final String? projectId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Uint8List> _selectedImages = [];
  bool _showImagePicker = false;

  @override
  void initState() {
    super.initState();
    // Initialize providers after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Initialize project provider first
      projectProvider.initialize().then((_) {
        // If specific project ID is provided, switch to it
        if (widget.projectId != null) {
          projectProvider.switchToProject(widget.projectId!);
        }

        // Initialize chat provider
        chatProvider.initialize().then((_) {
          // Set language provider for localized responses
          final languageProvider = Provider.of<LanguageProvider>(
            context,
            listen: false,
          );
          chatProvider.setLanguageProvider(languageProvider);
          
          // Set project provider for instant UI updates
          chatProvider.setProjectProvider(projectProvider);
          
          // Load current project messages into ChatProvider
          _syncProjectMessagesToChat(projectProvider, chatProvider);
        });
      });

      // Note: No longer need to listen to project changes for message sync
      // ChatProvider now manages ProjectProvider directly for instant UI updates
    });
  }

  /// Sync current project messages to ChatProvider
  void _syncProjectMessagesToChat(
    ProjectProvider projectProvider,
    ChatProvider chatProvider,
  ) {
    final currentProject = projectProvider.currentProject;
    if (currentProject != null) {
      // Load project messages into ChatProvider's current session
      // This ensures ChatProvider has the correct conversation history
      chatProvider.loadMessagesFromProject(currentProject.messages);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LanguageProvider, ProjectProvider, ChatProvider>(
      builder:
          (context, languageProvider, projectProvider, chatProvider, child) {
            // Set language provider after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              chatProvider.setLanguageProvider(languageProvider);
              projectProvider.setLanguageProvider(languageProvider);
            });

            return Scaffold(
              appBar: AppBar(
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                title: Row(
                  children: [
                    const SmallLogoWidget(size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProjectTitle(
                        projectProvider,
                        languageProvider,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showNewProjectDialog(
                        context,
                        projectProvider,
                        languageProvider,
                      );
                    },
                    tooltip: languageProvider.getString('newProject'),
                  ),
                ],
              ),
              drawer: const ProjectsSidebar(),
              body: Column(
                children: [
                  // Chat messages area
                  Expanded(
                    child: _buildChatContent(chatProvider, projectProvider),
                  ),
                  // Message input area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image picker
                        if (_showImagePicker) ...[
                          ImagePickerWidget(
                            onImagesSelected: (images) {
                              setState(() {
                                _selectedImages = images;
                                if (images.isEmpty) {
                                  _showImagePicker = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Message input row
                        Row(
                          children: [
                            // Image picker button
                            IconButton(
                              onPressed: chatProvider.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        if (_showImagePicker) {
                                          _showImagePicker = false;
                                          _selectedImages.clear();
                                        } else {
                                          _showImagePicker = true;
                                        }
                                      });
                                    },
                              icon: Icon(
                                _showImagePicker
                                    ? Icons.close
                                    : Icons.add_photo_alternate,
                                color: _showImagePicker
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: _showImagePicker
                                      ? languageProvider.getString(
                                          'messageHintWithImage',
                                        )
                                      : languageProvider.getString(
                                          'messageHintExtended',
                                        ),
                                  border: const OutlineInputBorder(),
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                enabled: !chatProvider.isLoading,
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty &&
                                      !chatProvider.isLoading) {
                                    _sendMessage(
                                      chatProvider,
                                      projectProvider,
                                      value.trim(),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: chatProvider.isLoading
                                  ? null
                                  : () {
                                      final message = _messageController.text
                                          .trim();
                                      if (message.isNotEmpty) {
                                        _sendMessage(
                                          chatProvider,
                                          projectProvider,
                                          message,
                                        );
                                      }
                                    },
                              icon: chatProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  /// Builds the chat content area
  Widget _buildChatContent(
    ChatProvider chatProvider,
    ProjectProvider projectProvider,
  ) {
    final currentProject = projectProvider.currentProject;

    // ONLY messages from the current project
    final messages = currentProject?.messages ?? [];

    if (messages.isEmpty) {
      return _buildWelcomeScreen(chatProvider);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message,
          onRetry: message.isError
              ? () {
                  // Retry will re-send the message
                  final lastUserMessage = messages.lastWhere(
                    (m) => m.type == MessageType.user,
                    orElse: () => message,
                  );
                  if (lastUserMessage.type == MessageType.user) {
                    _sendMessage(
                      chatProvider,
                      projectProvider,
                      lastUserMessage.content,
                    );
                  }
                }
              : null,
        );
      },
    );
  }

  /// Builds the welcome screen when no messages exist
  Widget _buildWelcomeScreen(ChatProvider chatProvider) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoWidget(size: 120),
              const SizedBox(height: 32),
              Text(
                languageProvider.getString('welcomeTitle'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                languageProvider.getString('welcomeSubtitle'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider.getString('getStarted'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...chatProvider.getQuickStartSuggestions().map(
                        (suggestion) =>
                            _buildSuggestionItem(suggestion, chatProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a suggestion item
  Widget _buildSuggestionItem(String text, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          final projectProvider = Provider.of<ProjectProvider>(
            context,
            listen: false,
          );
          _sendMessage(chatProvider, projectProvider, text);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  /// Sends a message to the AI
  Future<void> _sendMessage(
    ChatProvider chatProvider,
    ProjectProvider projectProvider,
    String message,
  ) async {
    final currentProject = projectProvider.currentProject;
    if (currentProject == null) return;

    // Clear message controller IMMEDIATELY
    _messageController.clear();

    // Check if we need to auto-rename BEFORE sending message
    final shouldAutoRename = currentProject.messages.isEmpty &&
        (currentProject.title.startsWith('Новый проект') ||
            currentProject.title == 'New Project');
    
    // Send message through ChatProvider
    if (_selectedImages.isNotEmpty) {
      await chatProvider.sendMessageWithImages(
        content: message,
        images: _selectedImages,
      );
      setState(() {
        _selectedImages.clear();
        _showImagePicker = false;
      });
    } else {
      await chatProvider.sendMessage(message);
    }

    // Auto-rename project if needed
    if (shouldAutoRename) {
      final newTitle = message.length > 50
          ? '${message.substring(0, 50)}...'
          : message;
      
      debugPrint('🏷️ Auto-renaming new project to: "$newTitle"');
      await projectProvider.renameProject(currentProject.id, newTitle);
    }

    _scrollToBottom();
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Build project title
  Widget _buildProjectTitle(
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    final currentProject = projectProvider.currentProject;

    if (currentProject == null) {
      return Text(
        languageProvider.getString('currentProject'),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      );
    }

    return Row(
      children: [
        Icon(
          Icons.folder_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            currentProject.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _showRenameDialog(
            context,
            projectProvider,
            currentProject,
            languageProvider,
          ),
          tooltip: languageProvider.getString('renameProject'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  /// Shows the new project dialog
  void _showNewProjectDialog(
    BuildContext context,
    ProjectProvider projectProvider,
    LanguageProvider languageProvider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => NewProjectDialog(
        onProjectCreated: (title) {
          projectProvider.createNewProject(title: title);
          Navigator.of(context).pop(); // Close dialog
        },
      ),
    );
  }

  /// Shows the rename project dialog
  void _showRenameDialog(
    BuildContext context,
    ProjectProvider projectProvider,
    Project project,
    LanguageProvider languageProvider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => RenameProjectDialog(
        currentTitle: project.title,
        onRenamed: (newTitle) {
          projectProvider.renameProject(project.id, newTitle);
        },
      ),
    );
  }
}
