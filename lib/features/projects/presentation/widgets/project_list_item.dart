/// Project list item widget
/// 
/// This widget displays an individual project in the projects list
/// with title, preview, and metadata.
library;

import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';

/// Project list item widget
class ProjectListItem extends StatelessWidget {
  /// Creates a project list item
  const ProjectListItem({
    super.key,
    required this.project,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  /// The project to display
  final Project project;

  /// Whether this project is currently active
  final bool isActive;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Callback when the item is long pressed
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isActive 
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isActive 
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and favorite indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (project.isFavorite)
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Preview text
                if (project.previewText != null) ...[
                  Text(
                    project.previewText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive 
                        ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Metadata row
                Row(
                  children: [
                    // Message count
                    if (project.messageCount > 0) ...[
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 12,
                        color: isActive 
                          ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.messageCount.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    // Last modified time
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: isActive 
                        ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        project.lastModifiedRelative,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
