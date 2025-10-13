/// Custom text field widget following the LandComp style guide
/// 
/// This widget implements a text field with proper styling,
/// states, and animations according to the design system.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:landcomp_app/core/theme/colors.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';

/// Text field state enumeration
enum TextFieldState {
  /// Default state
  normal,
  /// Focused state
  focused,
  /// Error state
  error,
  /// Success state
  success,
  /// Disabled state
  disabled,
}

/// Custom text field widget
class CustomTextField extends StatefulWidget {
  /// Creates a custom text field
  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.state = TextFieldState.normal,
    this.width,
    this.height,
  });

  /// Text editing controller
  final TextEditingController? controller;

  /// Focus node
  final FocusNode? focusNode;

  /// Label text
  final String? labelText;

  /// Hint text
  final String? hintText;

  /// Helper text
  final String? helperText;

  /// Error text
  final String? errorText;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Whether text is obscured
  final bool obscureText;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Maximum lines
  final int? maxLines;

  /// Maximum length
  final int? maxLength;

  /// Whether field is enabled
  final bool enabled;

  /// Whether field is read-only
  final bool readOnly;

  /// Whether field should autofocus
  final bool autofocus;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submitted callback
  final ValueChanged<String>? onSubmitted;

  /// On tap callback
  final VoidCallback? onTap;

  /// Validator function
  final String? Function(String?)? validator;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Field state
  final TextFieldState state;

  /// Field width
  final double? width;

  /// Field height
  final double? height;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationStandard,
      vsync: this,
    );
    _focusAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.state != TextFieldState.disabled;
    final hasError = widget.state == TextFieldState.error || widget.errorText != null;
    final hasSuccess = widget.state == TextFieldState.success;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _focusAnimation,
        builder: (context, child) {
          return TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: isEnabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            style: AppTypography.body.copyWith(
              color: isEnabled 
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _getIconColor(hasError, hasSuccess),
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? Icon(
                      widget.suffixIcon,
                      color: _getIconColor(hasError, hasSuccess),
                    )
                  : null,
              filled: true,
              fillColor: _getFillColor(isEnabled),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
                borderSide: BorderSide(
                  color: _getBorderColor(hasError, hasSuccess),
                  width: DesignTokens.inputBorderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
                borderSide: BorderSide(
                  color: _getBorderColor(hasError, hasSuccess),
                  width: DesignTokens.inputBorderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
                borderSide: BorderSide(
                  color: _getFocusedBorderColor(hasError, hasSuccess),
                  width: DesignTokens.inputBorderWidth,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: DesignTokens.inputBorderWidth,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.inputBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: DesignTokens.inputBorderWidth,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              labelStyle: AppTypography.body.copyWith(
                color: _getLabelColor(hasError, hasSuccess),
              ),
              hintStyle: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              helperStyle: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              errorStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get fill color based on state
  Color _getFillColor(bool isEnabled) {
    if (!isEnabled) {
      return AppColors.gray50;
    }
    return Theme.of(context).colorScheme.surface;
  }

  /// Get border color based on state
  Color _getBorderColor(bool hasError, bool hasSuccess) {
    if (hasError) {
      return AppColors.error;
    }
    if (hasSuccess) {
      return AppColors.success;
    }
    return Theme.of(context).colorScheme.outline;
  }

  /// Get focused border color based on state
  Color _getFocusedBorderColor(bool hasError, bool hasSuccess) {
    if (hasError) {
      return AppColors.error;
    }
    if (hasSuccess) {
      return AppColors.success;
    }
    return AppColors.primaryGreen;
  }

  /// Get icon color based on state
  Color _getIconColor(bool hasError, bool hasSuccess) {
    if (hasError) {
      return AppColors.error;
    }
    if (hasSuccess) {
      return AppColors.success;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Get label color based on state
  Color _getLabelColor(bool hasError, bool hasSuccess) {
    if (hasError) {
      return AppColors.error;
    }
    if (hasSuccess) {
      return AppColors.success;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}
