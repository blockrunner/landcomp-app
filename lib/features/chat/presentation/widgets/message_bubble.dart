/// Message bubble widget for displaying chat messages
/// 
/// This widget displays different types of messages with
/// appropriate styling and animations.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/shared/widgets/image_viewer.dart';
import 'package:landcomp_app/features/chat/data/config/ai_agents_config.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';

/// Message bubble widget
class MessageBubble extends StatelessWidget {
  /// Creates a message bubble
  const MessageBubble({
    required this.message, super.key,
    this.onRetry,
    this.onDelete,
    this.showTimestamp = true,
  });

  /// The message to display
  final Message message;

  /// Callback for retry action
  final VoidCallback? onRetry;

  /// Callback for delete action
  final VoidCallback? onDelete;

  /// Whether to show timestamp
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: _getCrossAxisAlignment(),
        children: [
          _buildMessageContent(context),
          if (showTimestamp) ...[
            const SizedBox(height: 4),
            _buildTimestamp(context),
          ],
        ],
      ),
    );
  }

  /// Get cross axis alignment based on message type
  CrossAxisAlignment _getCrossAxisAlignment() {
    switch (message.type) {
      case MessageType.user:
        return CrossAxisAlignment.end;
      case MessageType.ai:
        return CrossAxisAlignment.start;
      case MessageType.system:
        return CrossAxisAlignment.center;
    }
  }

  /// Build message content
  Widget _buildMessageContent(BuildContext context) {
    if (message.isTyping) {
      return _buildTypingIndicator(context);
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: _buildMessageBubble(context),
    );
  }

  /// Build message bubble
  Widget _buildMessageBubble(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isError = message.isError;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBubbleColor(context, isUser, isError),
        borderRadius: _getBorderRadius(isUser),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && message.type == MessageType.ai) ...[
            _buildAgentHeader(context),
            const SizedBox(height: 8),
          ],
          // Show attachments if present
          if (message.attachments != null && message.attachments!.isNotEmpty) ...[
            _buildAttachments(context),
            if (message.content.isNotEmpty) const SizedBox(height: 8),
          ],
          // Show text content
          if (message.content.isNotEmpty) _buildMessageText(context, isError),
          if (isError && onRetry != null) ...[
            const SizedBox(height: 8),
            _buildRetryButton(context),
          ],
        ],
      ),
    );
  }

  /// Build agent header for AI messages
  Widget _buildAgentHeader(BuildContext context) {
    final agent = AIAgentsConfig.getAgentById(message.agentId ?? '');
    if (agent == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: agent.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            agent.icon,
            size: 16,
            color: agent.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          agent.name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: agent.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build message text
  Widget _buildMessageText(BuildContext context, bool isError) {
    final theme = Theme.of(context);
    final isUser = message.type == MessageType.user;

    return Text(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: _getTextColor(context, isUser, isError),
        height: 1.4,
      ),
    );
  }

  /// Build retry button for error messages
  Widget _buildRetryButton(BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 16),
        label: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) => Text(languageProvider.getString('retry')),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 32),
        ),
      ),
    );
  }

  /// Build typing indicator
  Widget _buildTypingIndicator(BuildContext context) {
    final agent = AIAgentsConfig.getAgentById(message.agentId ?? '');
    if (agent == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: agent.primaryColor.withOpacity(0.1),
        borderRadius: _getBorderRadius(false),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: agent.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              agent.icon,
              size: 16,
              color: agent.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          _buildTypingDots(context, agent.primaryColor),
        ],
      ),
    );
  }

  /// Build typing dots animation
  Widget _buildTypingDots(BuildContext context, Color color) {
    return SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              final delay = index * 0.2;
              final animationValue = (value - delay).clamp(0.0, 1.0);
              final scale = 0.5 + (0.5 * animationValue);
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// Build timestamp
  Widget _buildTimestamp(BuildContext context) {
    final theme = Theme.of(context);
    final time = _formatTime(context, message.timestamp);

    return Text(
      time,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.textTheme.bodySmall?.color,
      ),
    );
  }

  /// Get bubble color based on message type
  Color _getBubbleColor(BuildContext context, bool isUser, bool isError) {
    final theme = Theme.of(context);
    
    if (isError) {
      return theme.colorScheme.errorContainer;
    }
    
    if (isUser) {
      return theme.colorScheme.primary;
    }
    
    return theme.colorScheme.surfaceContainerHighest;
  }

  /// Get text color based on message type
  Color _getTextColor(BuildContext context, bool isUser, bool isError) {
    final theme = Theme.of(context);
    
    if (isError) {
      return theme.colorScheme.onErrorContainer;
    }
    
    if (isUser) {
      return theme.colorScheme.onPrimary;
    }
    
    return theme.colorScheme.onSurfaceVariant;
  }

  /// Get border radius based on message type
  BorderRadius _getBorderRadius(bool isUser) {
    if (isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    }
  }

  /// Build attachments display
  Widget _buildAttachments(BuildContext context) {
    print('📎 MessageBubble: Building attachments for message ${message.id}');
    print('📎 Message type: ${message.type}');
    print('📎 Attachments: ${message.attachments?.length ?? 0}');
    if (message.attachments != null && message.attachments!.isNotEmpty) {
      print('📎 Attachment types: ${message.attachments!.map((a) => a.type.name).toList()}');
    }
    
    if (message.attachments == null || message.attachments!.isEmpty) {
      print('📎 No attachments to display');
      return const SizedBox.shrink();
    }

    final imageAttachments = message.attachments!.where((a) => a.isImage).toList();
    final otherAttachments = message.attachments!.where((a) => !a.isImage).toList();
    
    // Separate original and generated images
    final originalImages = imageAttachments.where((a) => a.name.startsWith('image_')).toList();
    final generatedImages = imageAttachments.where((a) => a.name.startsWith('generated_')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show original images (from user)
        if (originalImages.isNotEmpty) ...[
          _buildImageSection(context, originalImages, context.read<LanguageProvider>().getString('originalImages')),
        ],
        
        // Show generated images (from AI)
        if (generatedImages.isNotEmpty) ...[
          if (originalImages.isNotEmpty) const SizedBox(height: 16),
          _buildImageSection(context, generatedImages, context.read<LanguageProvider>().getString('generatedVariants')),
        ],
        
        // Show other attachments
        if (otherAttachments.isNotEmpty) ...[
          if (imageAttachments.isNotEmpty) const SizedBox(height: 8),
          ...otherAttachments.map((attachment) => _buildFileAttachment(context, attachment)),
        ],
      ],
    );
  }

  /// Build image section with title
  Widget _buildImageSection(BuildContext context, List<Attachment> images, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Images
        if (images.length == 1) ...[
          // Single image
          _buildImageAttachment(context, images.first, images),
        ] else ...[
          // Multiple images
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images.asMap().entries.map((entry) {
              final index = entry.key;
              final attachment = entry.value;
              return _buildImageThumbnail(context, attachment, images, index);
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Build single image attachment
  Widget _buildImageAttachment(BuildContext context, Attachment attachment, List<Attachment> allImages) {
    return _buildImageWithHover(
      context: context,
      attachment: attachment,
      allImages: allImages,
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 250,
      ),
    );
  }

  /// Build image thumbnail
  Widget _buildImageThumbnail(BuildContext context, Attachment attachment, List<Attachment> allImages, int index) {
    return _buildImageWithHover(
      context: context,
      attachment: attachment,
      allImages: allImages,
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 100,
        minHeight: 100,
        maxHeight: 100,
      ),
    );
  }

  /// Build file attachment
  Widget _buildFileAttachment(BuildContext context, Attachment attachment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(attachment.mimeType),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attachment.displaySize,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// Get file icon based on MIME type
  IconData _getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word')) return Icons.description;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) return Icons.table_chart;
    if (mimeType.contains('zip') || mimeType.contains('rar')) return Icons.archive;
    return Icons.attach_file;
  }

  /// Format timestamp for display
  String _formatTime(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${context.read<LanguageProvider>().getString('hoursAgo')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${context.read<LanguageProvider>().getString('minutesAgo')}';
    } else {
      return context.read<LanguageProvider>().getString('justNow');
    }
  }

  /// Open image viewer
  void _openImageViewer(BuildContext context, List<Attachment> images, int initialIndex) {
    showImageViewer(
      context: context,
      attachments: images,
      initialIndex: initialIndex,
      title: images.length > 1 ? context.read<LanguageProvider>().getString('images') : context.read<LanguageProvider>().getString('image'),
    );
  }

  /// Build image with hover effect
  Widget _buildImageWithHover({
    required BuildContext context,
    required Attachment attachment,
    required List<Attachment> allImages,
    required BoxConstraints constraints,
  }) {
    return _ImageWithHover(
      attachment: attachment,
      allImages: allImages,
      constraints: constraints,
      onTap: () => _openImageViewer(context, allImages, allImages.indexOf(attachment)),
    );
  }
}

/// Widget for image with hover effect
class _ImageWithHover extends StatefulWidget {
  const _ImageWithHover({
    required this.attachment,
    required this.allImages,
    required this.constraints,
    required this.onTap,
  });

  final Attachment attachment;
  final List<Attachment> allImages;
  final BoxConstraints constraints;
  final VoidCallback onTap;

  @override
  State<_ImageWithHover> createState() => _ImageWithHoverState();
}

class _ImageWithHoverState extends State<_ImageWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: widget.constraints,
            child: Stack(
              children: [
                // Image with proper aspect ratio
                if (widget.attachment.hasData)
                  _buildImageWithAspectRatio()
                else
                  _buildImageError(context, widget.constraints.maxWidth, widget.constraints.maxHeight),
                
                // Hover overlay with gradient
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(_isHovered ? 0.3 : 0.0),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(_isHovered ? 0.3 : 0.0),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build image with proper aspect ratio
  Widget _buildImageWithAspectRatio() {
    if (!widget.attachment.hasData) {
      return _buildImageError(context, widget.constraints.maxWidth, widget.constraints.maxHeight);
    }

    // Calculate aspect ratio from image dimensions
    var aspectRatio = 1.0; // Default square
    if (widget.attachment.width != null && widget.attachment.height != null) {
      aspectRatio = widget.attachment.width! / widget.attachment.height!;
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.memory(
        widget.attachment.data!,
        fit: BoxFit.cover, // Use cover to fill the aspect ratio container
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError(context, widget.constraints.maxWidth, widget.constraints.maxHeight);
        },
      ),
    );
  }

  /// Build image error widget
  Widget _buildImageError(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: width > 150 ? 32 : 24,
          ),
          const SizedBox(height: 8),
          Text(
            context.read<LanguageProvider>().getString('loadingError'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
