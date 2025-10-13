/// Plant card widget following the LandComp style guide
/// 
/// This widget displays plant information in a card format
/// with image, characteristics, and action button.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';
import 'package:landcomp_app/shared/widgets/cards/base_card.dart';
import 'package:landcomp_app/shared/widgets/buttons/button_factory.dart';

/// Plant data model
class PlantData {
  /// Creates plant data
  const PlantData({
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    this.height,
    this.seasonality,
    this.description,
    this.isAdded = false,
  });

  /// Plant common name
  final String name;

  /// Plant scientific name
  final String scientificName;

  /// Plant image URL
  final String imageUrl;

  /// Plant height
  final String? height;

  /// Plant seasonality
  final String? seasonality;

  /// Plant description
  final String? description;

  /// Whether plant is added to composition
  final bool isAdded;
}

/// Plant card widget
class PlantCard extends StatelessWidget {
  /// Creates a plant card
  const PlantCard({
    required this.plant, super.key,
    this.onAddToComposition,
    this.onTap,
    this.width,
    this.height,
  });

  /// Plant data
  final PlantData plant;

  /// Callback when add to composition is pressed
  final VoidCallback? onAddToComposition;

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
        semanticLabel: 'Plant card for ${plant.name}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            const SizedBox(height: AppSpacing.md),
            _buildContent(context),
            const SizedBox(height: AppSpacing.md),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  /// Build plant image
  Widget _buildImage(BuildContext context) {
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
          child: plant.imageUrl.isNotEmpty
              ? Image.network(
                  plant.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder(context);
                  },
                )
              : _buildImagePlaceholder(context),
        ),
      ),
    );
  }

  /// Build image placeholder
  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: const Center(
        child: Icon(
          Icons.local_florist,
          size: DesignTokens.iconSizeXXLarge,
          color: AppColors.gray500,
        ),
      ),
    );
  }

  /// Build card content
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plant.name,
          style: AppTypography.h6.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          plant.scientificName,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (plant.description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            plant.description!,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _buildCharacteristics(context),
      ],
    );
  }

  /// Build plant characteristics
  Widget _buildCharacteristics(BuildContext context) {
    return Row(
      children: [
        if (plant.height != null) ...[
          _buildCharacteristic(
            context,
            Icons.height,
            plant.height!,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        if (plant.seasonality != null)
          _buildCharacteristic(
            context,
            Icons.calendar_today,
            plant.seasonality!,
          ),
      ],
    );
  }

  /// Build single characteristic
  Widget _buildCharacteristic(
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

  /// Build action button
  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: plant.isAdded
          ? ButtonFactory.secondary(
              onPressed: onAddToComposition,
              child: const Text('Добавлено'),
            )
          : ButtonFactory.primary(
              onPressed: onAddToComposition,
              child: const Text('Добавить в композицию'),
            ),
    );
  }
}

/// Compact plant card for lists
class CompactPlantCard extends StatelessWidget {
  /// Creates a compact plant card
  const CompactPlantCard({
    required this.plant, super.key,
    this.onTap,
    this.onAddToComposition,
  });

  /// Plant data
  final PlantData plant;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when add to composition is pressed
  final VoidCallback? onAddToComposition;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      semanticLabel: 'Compact plant card for ${plant.name}',
      child: Row(
        children: [
          _buildCompactImage(context),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildCompactContent(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildCompactActionButton(context),
        ],
      ),
    );
  }

  /// Build compact image
  Widget _buildCompactImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
        child: plant.imageUrl.isNotEmpty
            ? Image.network(
                plant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCompactImagePlaceholder(context);
                },
              )
            : _buildCompactImagePlaceholder(context),
      ),
    );
  }

  /// Build compact image placeholder
  Widget _buildCompactImagePlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: const Center(
        child: Icon(
          Icons.local_florist,
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
        Text(
          plant.name,
          style: AppTypography.body.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          plant.scientificName,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Build compact action button
  Widget _buildCompactActionButton(BuildContext context) {
    return plant.isAdded
        ? const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: DesignTokens.iconSizeLarge,
          )
        : ButtonFactory.primaryIcon(
            onPressed: onAddToComposition,
            icon: Icons.add,
          );
  }
}
