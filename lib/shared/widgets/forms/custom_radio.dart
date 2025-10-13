/// Custom radio button widget following the LandComp style guide
///
/// This widget implements a radio button with proper styling,
/// animations, and accessibility according to the design system.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';

/// Custom radio button widget
class CustomRadio<T> extends StatefulWidget {
  /// Creates a custom radio button
  const CustomRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
    this.label,
    this.activeColor,
    this.focusColor,
    this.hoverColor,
    this.semanticLabel,
    this.autofocus = false,
    this.materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
  });

  /// The value represented by this radio button
  final T value;

  /// The currently selected value for a group of radio buttons
  final T? groupValue;

  /// Called when the user selects this radio button
  final ValueChanged<T?>? onChanged;

  /// Optional label text
  final String? label;

  /// The color to use when this radio button is selected
  final Color? activeColor;

  /// The color for the radio button's Material when it has the input focus
  final Color? focusColor;

  /// The color for the radio button's Material when a pointer is hovering over it
  final Color? hoverColor;

  /// The semantic label for the radio button
  final String? semanticLabel;

  /// Whether this radio button should focus itself if nothing else is already focused
  final bool autofocus;

  /// Configures the minimum size of the tap target
  final MaterialTapTargetSize materialTapTargetSize;

  @override
  State<CustomRadio<T>> createState() => _CustomRadioState<T>();
}

class _CustomRadioState<T> extends State<CustomRadio<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _dotAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.value == widget.groupValue) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == widget.groupValue &&
        oldWidget.value != oldWidget.groupValue) {
      _animationController.forward();
    } else if (widget.value != widget.groupValue &&
        oldWidget.value == oldWidget.groupValue) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.value == widget.groupValue;
    final isEnabled = widget.onChanged != null;
    final activeColor = widget.activeColor ?? AppColors.primaryGreen;

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      checked: isSelected,
      child: InkWell(
        onTap: isEnabled ? () => widget.onChanged?.call(widget.value) : null,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? activeColor
                              : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: AnimatedBuilder(
                                animation: _dotAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _dotAnimation.value,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: activeColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
              if (widget.label != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    widget.label!,
                    style: AppTypography.body.copyWith(
                      color: isEnabled
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience widget for radio button with label
class RadioWithLabel<T> extends StatelessWidget {
  /// Creates a radio button with label
  const RadioWithLabel({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    super.key,
    this.activeColor,
    this.semanticLabel,
  });

  /// The value represented by this radio button
  final T value;

  /// The currently selected value for a group of radio buttons
  final T? groupValue;

  /// Called when the user selects this radio button
  final ValueChanged<T?>? onChanged;

  /// Label text
  final String label;

  /// The color to use when this radio button is selected
  final Color? activeColor;

  /// The semantic label for the radio button
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CustomRadio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      label: label,
      activeColor: activeColor,
      semanticLabel: semanticLabel,
    );
  }
}
