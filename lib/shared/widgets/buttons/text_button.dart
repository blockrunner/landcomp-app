/// Text button widget following the LandComp style guide
/// 
/// This widget implements the text button with transparent background
/// and proper hover states according to the design system.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';
import 'package:landcomp_app/shared/widgets/buttons/primary_button.dart';

/// Text button widget
class AppTextButton extends StatefulWidget {
  /// Creates a text button
  const AppTextButton({
    required this.onPressed, required this.child, super.key,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.icon,
    this.color,
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

  /// Button color (defaults to dark teal)
  final Color? color;

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton>
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
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.98,
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
    final isEnabled = widget.onPressed != null && 
                          !widget.isDisabled && 
                          !widget.isLoading;

    final buttonColor = widget.color ?? AppColors.darkTeal;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? (_) => _animationController.forward() : null,
            onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
            onTapCancel: isEnabled ? () => _animationController.reverse() : null,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              width: widget.width ?? _getButtonWidth(),
              height: _getButtonHeight(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  child: Container(
                    padding: _getButtonPadding(),
                    child: _buildButtonContent(buttonColor),
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
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
      case ButtonSize.icon:
        return EdgeInsets.zero;
    }
  }

  /// Build button content
  Widget _buildButtonContent(Color buttonColor) {
    if (widget.isLoading) {
      return _buildLoadingContent(buttonColor);
    }

    if (widget.size == ButtonSize.icon) {
      return _buildIconContent(buttonColor);
    }

    return _buildTextContent(buttonColor);
  }

  /// Build loading content
  Widget _buildLoadingContent(Color buttonColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
          ),
        ),
        if (widget.size != ButtonSize.icon) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Loading...',
            style: _getTextStyle().copyWith(
              color: buttonColor,
            ),
          ),
        ],
      ],
    );
  }

  /// Build icon content
  Widget _buildIconContent(Color buttonColor) {
    return Icon(
      widget.icon ?? Icons.add,
      color: buttonColor,
      size: DesignTokens.iconSizeLarge,
    );
  }

  /// Build text content
  Widget _buildTextContent(Color buttonColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: buttonColor,
            size: DesignTokens.iconSizeMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        DefaultTextStyle(
          style: _getTextStyle().copyWith(
            color: buttonColor,
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
class AppTextButtonLarge extends AppTextButton {
  const AppTextButtonLarge({
    required super.onPressed, required super.child, super.key,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.icon,
    super.color,
  }) : super(size: ButtonSize.large);
}

class AppTextButtonSmall extends AppTextButton {
  const AppTextButtonSmall({
    required super.onPressed, required super.child, super.key,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.icon,
    super.color,
  }) : super(size: ButtonSize.small);
}

class AppTextButtonIcon extends AppTextButton {
  const AppTextButtonIcon({
    required super.onPressed, required super.icon, super.key,
    super.isLoading,
    super.isDisabled,
    super.color,
  }) : super(
          size: ButtonSize.icon,
          child: const SizedBox.shrink(),
        );
}
