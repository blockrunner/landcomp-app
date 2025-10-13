/// Base card widget following the LandComp style guide
/// 
/// This widget provides the foundation for all card components
/// with consistent styling, shadows, and hover animations.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';

/// Base card widget
class BaseCard extends StatefulWidget {
  /// Creates a base card
  const BaseCard({
    required this.child, super.key,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.enableHover = true,
  });

  /// Card content
  final Widget child;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Card background color
  final Color? color;

  /// Card elevation (shadow)
  final double? elevation;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Border
  final Border? border;

  /// On tap callback
  final VoidCallback? onTap;

  /// On long press callback
  final VoidCallback? onLongPress;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Whether to enable hover effects
  final bool enableHover;

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _transformAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationStandard,
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _transformAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -4),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final cardColor = widget.color ?? Theme.of(context).colorScheme.surface;
    final cardBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(DesignTokens.cardBorderRadius);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _transformAnimation.value,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: cardBorderRadius,
              border: widget.border,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 12,
                ),
                if (_elevationAnimation.value > 0)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                borderRadius: cardBorderRadius,
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(AppSpacing.internalPadding),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Card with default styling
class Card extends StatelessWidget {
  /// Creates a card with default styling
  const Card({
    required this.child, super.key,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  /// Card content
  final Widget child;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Card background color
  final Color? color;

  /// On tap callback
  final VoidCallback? onTap;

  /// On long press callback
  final VoidCallback? onLongPress;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: padding,
      margin: margin,
      color: color,
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}

/// Elevated card with shadow
class ElevatedCard extends StatelessWidget {
  /// Creates an elevated card
  const ElevatedCard({
    required this.child, super.key,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  /// Card content
  final Widget child;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Card background color
  final Color? color;

  /// Card elevation
  final double? elevation;

  /// On tap callback
  final VoidCallback? onTap;

  /// On long press callback
  final VoidCallback? onLongPress;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: padding,
      margin: margin,
      color: color,
      elevation: elevation ?? 2.0,
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}

/// Outlined card with border
class OutlinedCard extends StatelessWidget {
  /// Creates an outlined card
  const OutlinedCard({
    required this.child, super.key,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  /// Card content
  final Widget child;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Card background color
  final Color? color;

  /// Border color
  final Color? borderColor;

  /// Border width
  final double? borderWidth;

  /// On tap callback
  final VoidCallback? onTap;

  /// On long press callback
  final VoidCallback? onLongPress;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: padding,
      margin: margin,
      color: color,
      border: Border.all(
        color: borderColor ?? Theme.of(context).colorScheme.outline,
        width: borderWidth ?? 1.0,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}
