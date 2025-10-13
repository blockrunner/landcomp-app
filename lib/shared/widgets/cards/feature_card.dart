/// Feature card widget following the LandComp style guide
///
/// This widget displays feature information in a card format
/// with icon, title, description, and availability indicator.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';
import 'package:landcomp_app/shared/widgets/cards/base_card.dart';

/// Feature data model
class FeatureData {
  /// Creates feature data
  const FeatureData({
    required this.title,
    required this.description,
    required this.icon,
    this.isAvailable = true,
    this.isComingSoon = false,
    this.onTap,
  });

  /// Feature title
  final String title;

  /// Feature description
  final String description;

  /// Feature icon
  final IconData icon;

  /// Whether feature is available
  final bool isAvailable;

  /// Whether feature is coming soon
  final bool isComingSoon;

  /// On tap callback
  final VoidCallback? onTap;
}

/// Feature card widget
class FeatureCard extends StatelessWidget {
  /// Creates a feature card
  const FeatureCard({
    required this.feature,
    super.key,
    this.width,
    this.height,
  });

  /// Feature data
  final FeatureData feature;

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
        onTap: feature.isAvailable ? feature.onTap : null,
        semanticLabel: 'Feature card for ${feature.title}',
        enableHover: feature.isAvailable,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.md),
            _buildContent(context),
            const SizedBox(height: AppSpacing.md),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  /// Build card header with icon
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: DesignTokens.iconSizeXXLarge,
          height: DesignTokens.iconSizeXXLarge,
          decoration: BoxDecoration(
            color: _getIconBackgroundColor(context),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          child: Icon(
            feature.icon,
            size: DesignTokens.iconSizeLarge,
            color: _getIconColor(context),
          ),
        ),
        const Spacer(),
        _buildAvailabilityIndicator(context),
      ],
    );
  }

  /// Build card content
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          feature.title,
          style: AppTypography.h6.copyWith(color: _getTextColor(context)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          feature.description,
          style: AppTypography.bodySmall.copyWith(
            color: _getDescriptionColor(context),
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Build card footer
  Widget _buildFooter(BuildContext context) {
    if (!feature.isAvailable && !feature.isComingSoon) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (feature.isComingSoon) ...[
          const Icon(
            Icons.schedule,
            size: DesignTokens.iconSizeSmall,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Скоро',
            style: AppTypography.caption.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (feature.isAvailable) ...[
          const Icon(
            Icons.check_circle,
            size: DesignTokens.iconSizeSmall,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Доступно',
            style: AppTypography.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const Spacer(),
        if (feature.isAvailable && feature.onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: DesignTokens.iconSizeSmall,
            color: _getTextColor(context),
          ),
      ],
    );
  }

  /// Build availability indicator
  Widget _buildAvailabilityIndicator(BuildContext context) {
    if (feature.isComingSoon) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
        child: Text(
          'Скоро',
          style: AppTypography.caption.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else if (!feature.isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
        child: Text(
          'Недоступно',
          style: AppTypography.caption.copyWith(
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Get icon background color
  Color _getIconBackgroundColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray100;
    }
    if (feature.isComingSoon) {
      return AppColors.warning.withValues(alpha: 0.1);
    }
    return AppColors.primaryGreenLight;
  }

  /// Get icon color
  Color _getIconColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray500;
    }
    if (feature.isComingSoon) {
      return AppColors.warning;
    }
    return AppColors.primaryGreen;
  }

  /// Get text color
  Color _getTextColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray500;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get description color
  Color _getDescriptionColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray500;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

/// Compact feature card for lists
class CompactFeatureCard extends StatelessWidget {
  /// Creates a compact feature card
  const CompactFeatureCard({required this.feature, super.key});

  /// Feature data
  final FeatureData feature;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: feature.isAvailable ? feature.onTap : null,
      semanticLabel: 'Compact feature card for ${feature.title}',
      enableHover: feature.isAvailable,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(context),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            child: Icon(
              feature.icon,
              size: DesignTokens.iconSizeMedium,
              color: _getIconColor(context),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppTypography.body.copyWith(
                    color: _getTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  feature.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: _getDescriptionColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildAvailabilityIndicator(context),
        ],
      ),
    );
  }

  /// Build availability indicator
  Widget _buildAvailabilityIndicator(BuildContext context) {
    if (feature.isComingSoon) {
      return const Icon(
        Icons.schedule,
        size: DesignTokens.iconSizeSmall,
        color: AppColors.warning,
      );
    } else if (!feature.isAvailable) {
      return const Icon(
        Icons.block,
        size: DesignTokens.iconSizeSmall,
        color: AppColors.gray500,
      );
    } else {
      return const Icon(
        Icons.check_circle,
        size: DesignTokens.iconSizeSmall,
        color: AppColors.success,
      );
    }
  }

  /// Get icon background color
  Color _getIconBackgroundColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray100;
    }
    if (feature.isComingSoon) {
      return AppColors.warning.withValues(alpha: 0.1);
    }
    return AppColors.primaryGreenLight;
  }

  /// Get icon color
  Color _getIconColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray500;
    }
    if (feature.isComingSoon) {
      return AppColors.warning;
    }
    return AppColors.primaryGreen;
  }

  /// Get text color
  Color _getTextColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray500;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get description color
  Color _getDescriptionColor(BuildContext context) {
    if (!feature.isAvailable) {
      return AppColors.gray500;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}
