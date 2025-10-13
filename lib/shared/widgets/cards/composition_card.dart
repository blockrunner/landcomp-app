/// Composition card widget following the LandComp style guide
/// 
/// This widget displays composition information in a card format
/// with preview, title, description, and metadata.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';
import 'package:landcomp_app/shared/widgets/cards/base_card.dart';
import 'package:landcomp_app/shared/widgets/buttons/button_factory.dart';

/// Composition data model
class CompositionData {
  /// Creates composition data
  const CompositionData({
    required this.name,
    required this.description,
    this.previewImageUrl,
    this.plantCount,
    this.difficulty,
    this.season,
    this.createdAt,
    this.isPublic = false,
    this.isFavorite = false,
  });

  /// Composition name
  final String name;

  /// Composition description
  final String description;

  /// Preview image URL
  final String? previewImageUrl;

  /// Number of plants in composition
  final int? plantCount;

  /// Difficulty level (1-5)
  final int? difficulty;

  /// Season
  final String? season;

  /// Creation date
  final DateTime? createdAt;

  /// Whether composition is public
  final bool isPublic;

  /// Whether composition is favorite
  final bool isFavorite;
}

/// Composition card widget
class CompositionCard extends StatelessWidget {
  /// Creates a composition card
  const CompositionCard({
    required this.composition, super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onToggleFavorite,
    this.width,
    this.height,
  });

  /// Composition data
  final CompositionData composition;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when edit is pressed
  final VoidCallback? onEdit;

  /// Callback when delete is pressed
  final VoidCallback? onDelete;

  /// Callback when share is pressed
  final VoidCallback? onShare;

  /// Callback when favorite is toggled
  final VoidCallback? onToggleFavorite;

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
        semanticLabel: 'Composition card for ${composition.name}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.md),
            _buildPreview(context),
            const SizedBox(height: AppSpacing.md),
            _buildContent(context),
            const SizedBox(height: AppSpacing.md),
            _buildMetadata(context),
            const SizedBox(height: AppSpacing.md),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Build card header
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            composition.name,
            style: AppTypography.h5.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (composition.isPublic) ...[
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.public,
            size: DesignTokens.iconSizeSmall,
            color: AppColors.info,
          ),
        ],
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: onToggleFavorite,
          icon: Icon(
            composition.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: composition.isFavorite ? AppColors.error : AppColors.gray500,
            size: DesignTokens.iconSizeMedium,
          ),
        ),
      ],
    );
  }

  /// Build composition preview
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
          child: composition.previewImageUrl != null && composition.previewImageUrl!.isNotEmpty
              ? Image.network(
                  composition.previewImageUrl!,
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
              'Превью композиции',
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
    return Text(
      composition.description,
      style: AppTypography.body.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build metadata
  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        if (composition.plantCount != null) ...[
          _buildMetadataItem(
            context,
            Icons.local_florist,
            '${composition.plantCount} растений',
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        if (composition.difficulty != null) ...[
          _buildMetadataItem(
            context,
            Icons.star,
            'Сложность: ${composition.difficulty}/5',
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        if (composition.season != null)
          _buildMetadataItem(
            context,
            Icons.calendar_today,
            composition.season!,
          ),
      ],
    );
  }

  /// Build metadata item
  Widget _buildMetadataItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: DesignTokens.iconSizeSmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ButtonFactory.primarySmall(
            onPressed: onEdit,
            child: const Text('Редактировать'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ButtonFactory.secondaryIcon(
          onPressed: onShare,
          icon: Icons.share,
        ),
        const SizedBox(width: AppSpacing.sm),
        ButtonFactory.secondaryIcon(
          onPressed: onDelete,
          icon: Icons.delete,
        ),
      ],
    );
  }
}

/// Compact composition card for lists
class CompactCompositionCard extends StatelessWidget {
  /// Creates a compact composition card
  const CompactCompositionCard({
    required this.composition, super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
  });

  /// Composition data
  final CompositionData composition;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when edit is pressed
  final VoidCallback? onEdit;

  /// Callback when delete is pressed
  final VoidCallback? onDelete;

  /// Callback when favorite is toggled
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      semanticLabel: 'Compact composition card for ${composition.name}',
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
        child: composition.previewImageUrl != null && composition.previewImageUrl!.isNotEmpty
            ? Image.network(
                composition.previewImageUrl!,
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
                composition.name,
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (composition.isPublic) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.public,
                size: DesignTokens.iconSizeSmall,
                color: AppColors.info,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          composition.description,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (composition.plantCount != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${composition.plantCount} растений',
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onToggleFavorite,
          icon: Icon(
            composition.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: composition.isFavorite ? AppColors.error : AppColors.gray500,
            size: DesignTokens.iconSizeSmall,
          ),
        ),
        Row(
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
        ),
      ],
    );
  }
}
