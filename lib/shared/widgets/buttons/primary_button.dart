/// Primary button widget following the LandComp style guide
///
/// This widget implements the primary button with gradient background,
/// multiple sizes, and proper states according to the design system.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';

/// Button size variants
enum ButtonSize {
  /// Large button - 56px height
  large,

  /// Medium button - 48px height (default)
  medium,

  /// Small button - 40px height
  small,

  /// Icon button - 48px square
  icon,
}

/// Primary button widget
class PrimaryButton extends StatefulWidget {
  /// Creates a primary button
  const PrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.icon,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button content (usually text)
  final Widget child;

  /// Button size
  final ButtonSize size;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button is disabled
  final bool isDisabled;

  /// Button width (null for auto)
  final double? width;

  /// Optional icon to display
  final IconData? icon;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? (_) => _animationController.forward() : null,
            onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
            onTapCancel: isEnabled
                ? () => _animationController.reverse()
                : null,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              width: widget.width ?? _getButtonWidth(),
              height: _getButtonHeight(),
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? AppGradients.primary
                    : const LinearGradient(
                        colors: [AppColors.gray500, AppColors.gray500],
                      ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                boxShadow: isEnabled ? DesignTokens.buttonShadow : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMedium,
                  ),
                  child: Container(
                    padding: _getButtonPadding(),
                    child: _buildButtonContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get button height based on size
  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.large:
        return DesignTokens.buttonHeightLarge;
      case ButtonSize.medium:
        return DesignTokens.buttonHeightMedium;
      case ButtonSize.small:
        return DesignTokens.buttonHeightSmall;
      case ButtonSize.icon:
        return DesignTokens.buttonHeightIcon;
    }
  }

  /// Get button width based on size
  double _getButtonWidth() {
    switch (widget.size) {
      case ButtonSize.large:
        return double.infinity;
      case ButtonSize.medium:
        return double.infinity;
      case ButtonSize.small:
        return double.infinity;
      case ButtonSize.icon:
        return DesignTokens.buttonHeightIcon;
    }
  }

  /// Get button padding based on size
  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case ButtonSize.icon:
        return EdgeInsets.zero;
    }
  }

  /// Build button content
  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return _buildLoadingContent();
    }

    if (widget.size == ButtonSize.icon) {
      return _buildIconContent();
    }

    return _buildTextContent();
  }

  /// Build loading content
  Widget _buildLoadingContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        if (widget.size != ButtonSize.icon) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Loading...',
            style: _getTextStyle().copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ],
    );
  }

  /// Build icon content
  Widget _buildIconContent() {
    return Icon(
      widget.icon ?? Icons.add,
      color: Theme.of(context).colorScheme.onPrimary,
      size: DesignTokens.iconSizeLarge,
    );
  }

  /// Build text content
  Widget _buildTextContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: DesignTokens.iconSizeMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        DefaultTextStyle(
          style: _getTextStyle().copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          child: widget.child,
        ),
      ],
    );
  }

  /// Get text style based on button size
  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.large:
        return AppTypography.buttonLarge;
      case ButtonSize.medium:
        return AppTypography.button;
      case ButtonSize.small:
        return AppTypography.buttonSmall;
      case ButtonSize.icon:
        return AppTypography.button;
    }
  }
}

/// Convenience constructors for different button sizes
class PrimaryButtonLarge extends PrimaryButton {
  const PrimaryButtonLarge({
    required super.onPressed,
    required super.child,
    super.key,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.icon,
  }) : super(size: ButtonSize.large);
}

class PrimaryButtonSmall extends PrimaryButton {
  const PrimaryButtonSmall({
    required super.onPressed,
    required super.child,
    super.key,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.icon,
  }) : super(size: ButtonSize.small);
}

class PrimaryButtonIcon extends PrimaryButton {
  const PrimaryButtonIcon({
    required super.onPressed,
    required super.icon,
    super.key,
    super.isLoading,
    super.isDisabled,
  }) : super(size: ButtonSize.icon, child: const SizedBox.shrink());
}
