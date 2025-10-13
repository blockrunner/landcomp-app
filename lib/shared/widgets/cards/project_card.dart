/// Project card widget following the LandComp style guide
/// 
/// This widget displays project information in a card format
/// with preview, title, date, and action buttons.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';
import 'package:landcomp_app/shared/widgets/cards/base_card.dart';
import 'package:landcomp_app/shared/widgets/buttons/button_factory.dart';

/// Project data model
class ProjectData {
  /// Creates project data
  const ProjectData({
    required this.name,
    required this.createdAt,
    this.previewImageUrl,
    this.description,
    this.plantCount,
    this.isShared = false,
  });

  /// Project name
  final String name;

  /// Creation date
  final DateTime createdAt;

  /// Preview image URL
  final String? previewImageUrl;

  /// Project description
  final String? description;

  /// Number of plants in project
  final int? plantCount;

  /// Whether project is shared
  final bool isShared;
}

/// Project card widget
class ProjectCard extends StatelessWidget {
  /// Creates a project card
  const ProjectCard({
    required this.project, super.key,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onTap,
    this.width,
    this.height,
  });

  /// Project data
  final ProjectData project;

  /// Callback when edit is pressed
  final VoidCallback? onEdit;

  /// Callback when delete is pressed
  final VoidCallback? onDelete;

  /// Callback when share is pressed
  final VoidCallback? onShare;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Card width
  final double? width;

  /// Card height
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: BaseCard(
        onTap: onTap,
        semanticLabel: 'Project card for ${project.name}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(context),
            const SizedBox(height: AppSpacing.md),
            _buildContent(context),
            const SizedBox(height: AppSpacing.md),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Build project preview
  Widget _buildPreview(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          child: project.previewImageUrl != null && project.previewImageUrl!.isNotEmpty
              ? Image.network(
                  project.previewImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPreviewPlaceholder(context);
                  },
                )
              : _buildPreviewPlaceholder(context),
        ),
      ),
    );
  }

  /// Build preview placeholder
  Widget _buildPreviewPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.landscape,
              size: DesignTokens.iconSizeXXLarge,
              color: AppColors.gray500,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Превью проекта',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build card content
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project.name,
                style: AppTypography.h6.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (project.isShared) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.share,
                size: DesignTokens.iconSizeSmall,
                color: AppColors.info,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _formatDate(project.createdAt),
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (project.description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            project.description!,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (project.plantCount != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.local_florist,
                size: DesignTokens.iconSizeSmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${project.plantCount} растений',
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build action buttons
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ButtonFactory.secondarySmall(
            onPressed: onEdit,
            child: const Text('Редактировать'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ButtonFactory.textIcon(
          onPressed: onShare,
          icon: Icons.share,
          color: AppColors.info,
        ),
        const SizedBox(width: AppSpacing.sm),
        ButtonFactory.textIcon(
          onPressed: onDelete,
          icon: Icons.delete,
          color: AppColors.error,
        ),
      ],
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дня назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'неделю' : 'недели'} назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}

/// Compact project card for lists
class CompactProjectCard extends StatelessWidget {
  /// Creates a compact project card
  const CompactProjectCard({
    required this.project, super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// Project data
  final ProjectData project;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when edit is pressed
  final VoidCallback? onEdit;

  /// Callback when delete is pressed
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      semanticLabel: 'Compact project card for ${project.name}',
      child: Row(
        children: [
          _buildCompactPreview(context),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildCompactContent(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildCompactActions(context),
        ],
      ),
    );
  }

  /// Build compact preview
  Widget _buildCompactPreview(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
        child: project.previewImageUrl != null && project.previewImageUrl!.isNotEmpty
            ? Image.network(
                project.previewImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCompactPreviewPlaceholder(context);
                },
              )
            : _buildCompactPreviewPlaceholder(context),
      ),
    );
  }

  /// Build compact preview placeholder
  Widget _buildCompactPreviewPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: const Center(
        child: Icon(
          Icons.landscape,
          size: DesignTokens.iconSizeLarge,
          color: AppColors.gray500,
        ),
      ),
    );
  }

  /// Build compact content
  Widget _buildCompactContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project.name,
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (project.isShared) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.share,
                size: DesignTokens.iconSizeSmall,
                color: AppColors.info,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _formatDate(project.createdAt),
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (project.plantCount != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${project.plantCount} растений',
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// Build compact actions
  Widget _buildCompactActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonFactory.textIcon(
          onPressed: onEdit,
          icon: Icons.edit,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(width: AppSpacing.xs),
        ButtonFactory.textIcon(
          onPressed: onDelete,
          icon: Icons.delete,
          color: AppColors.error,
        ),
      ],
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дня назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'неделю' : 'недели'} назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
