/// Custom checkbox widget following the LandComp style guide
/// 
/// This widget implements a checkbox with proper styling,
/// animations, and accessibility according to the design system.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';

/// Custom checkbox widget
class CustomCheckbox extends StatefulWidget {
  /// Creates a custom checkbox
  const CustomCheckbox({
    required this.value, required this.onChanged, super.key,
    this.label,
    this.tristate = false,
    this.activeColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.semanticLabel,
    this.autofocus = false,
    this.materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
  });

  /// Whether this checkbox is checked
  final bool? value;

  /// Called when the value of the checkbox should change
  final ValueChanged<bool?>? onChanged;

  /// Optional label text
  final String? label;

  /// Whether the checkbox should support three states
  final bool tristate;

  /// The color to use when this checkbox is checked
  final Color? activeColor;

  /// The color to use for the check icon when this checkbox is checked
  final Color? checkColor;

  /// The color for the checkbox's Material when it has the input focus
  final Color? focusColor;

  /// The color for the checkbox's Material when a pointer is hovering over it
  final Color? hoverColor;

  /// The semantic label for the checkbox
  final String? semanticLabel;

  /// Whether this checkbox should focus itself if nothing else is already focused
  final bool autofocus;

  /// Configures the minimum size of the tap target
  final MaterialTapTargetSize materialTapTargetSize;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox>
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
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));


    if (widget.value ?? false) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value ?? false) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onChanged != null;
    final activeColor = widget.activeColor ?? AppColors.primaryGreen;
    final checkColor = widget.checkColor ?? Colors.white;

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      checked: widget.value ?? false,
      child: InkWell(
        onTap: isEnabled ? () => widget.onChanged?.call(!(widget.value ?? false)) : null,
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
                        color: widget.value ?? false 
                            ? activeColor 
                            : Colors.transparent,
                        border: Border.all(
                          color: widget.value ?? false 
                              ? activeColor 
                              : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: widget.value ?? false
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: checkColor,
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

/// Convenience widget for checkbox with label
class CheckboxWithLabel extends StatelessWidget {
  /// Creates a checkbox with label
  const CheckboxWithLabel({
    required this.value, required this.onChanged, required this.label, super.key,
    this.tristate = false,
    this.activeColor,
    this.checkColor,
    this.semanticLabel,
  });

  /// Whether this checkbox is checked
  final bool? value;

  /// Called when the value of the checkbox should change
  final ValueChanged<bool?>? onChanged;

  /// Label text
  final String label;

  /// Whether the checkbox should support three states
  final bool tristate;

  /// The color to use when this checkbox is checked
  final Color? activeColor;

  /// The color to use for the check icon when this checkbox is checked
  final Color? checkColor;

  /// The semantic label for the checkbox
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CustomCheckbox(
      value: value,
      onChanged: onChanged,
      label: label,
      activeColor: activeColor,
      checkColor: checkColor,
      semanticLabel: semanticLabel,
    );
  }
}
