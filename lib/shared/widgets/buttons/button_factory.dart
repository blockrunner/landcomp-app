/// Button factory for creating consistent buttons across the app
///
/// This factory provides a unified interface for creating different
/// types of buttons with consistent styling and behavior.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/shared/widgets/buttons/primary_button.dart';
import 'package:landcomp_app/shared/widgets/buttons/secondary_button.dart';
import 'package:landcomp_app/shared/widgets/buttons/text_button.dart';

/// Button type enumeration
enum ButtonType {
  /// Primary button with gradient background
  primary,

  /// Secondary button with light background and border
  secondary,

  /// Text button with transparent background
  text,
}

/// Button factory class
class ButtonFactory {
  /// Private constructor to prevent instantiation
  ButtonFactory._();

  /// Create a button based on type and parameters
  static Widget create({
    required ButtonType type,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
    Color? color,
  }) {
    switch (type) {
      case ButtonType.primary:
        return PrimaryButton(
          onPressed: onPressed,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          width: width,
          icon: icon,
          child: child,
        );
      case ButtonType.secondary:
        return SecondaryButton(
          onPressed: onPressed,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          width: width,
          icon: icon,
          child: child,
        );
      case ButtonType.text:
        return AppTextButton(
          onPressed: onPressed,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          width: width,
          icon: icon,
          color: color,
          child: child,
        );
    }
  }

  /// Create a primary button
  static Widget primary({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
  }) {
    return create(
      type: ButtonType.primary,
      onPressed: onPressed,
      child: child,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
    );
  }

  /// Create a secondary button
  static Widget secondary({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
  }) {
    return create(
      type: ButtonType.secondary,
      onPressed: onPressed,
      child: child,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
    );
  }

  /// Create a text button
  static Widget text({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
    Color? color,
  }) {
    return create(
      type: ButtonType.text,
      onPressed: onPressed,
      child: child,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
      color: color,
    );
  }

  /// Create a large primary button
  static Widget primaryLarge({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
  }) {
    return primary(
      onPressed: onPressed,
      child: child,
      size: ButtonSize.large,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
    );
  }

  /// Create a small primary button
  static Widget primarySmall({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
  }) {
    return primary(
      onPressed: onPressed,
      child: child,
      size: ButtonSize.small,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
    );
  }

  /// Create an icon primary button
  static Widget primaryIcon({
    required VoidCallback? onPressed,
    required IconData icon,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return primary(
      onPressed: onPressed,
      child: const SizedBox.shrink(),
      size: ButtonSize.icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
    );
  }

  /// Create a large secondary button
  static Widget secondaryLarge({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
  }) {
    return secondary(
      onPressed: onPressed,
      child: child,
      size: ButtonSize.large,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
    );
  }

  /// Create a small secondary button
  static Widget secondarySmall({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
  }) {
    return secondary(
      onPressed: onPressed,
      child: child,
      size: ButtonSize.small,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
    );
  }

  /// Create an icon secondary button
  static Widget secondaryIcon({
    required VoidCallback? onPressed,
    required IconData icon,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return secondary(
      onPressed: onPressed,
      child: const SizedBox.shrink(),
      size: ButtonSize.icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
    );
  }

  /// Create a large text button
  static Widget textLarge({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
    Color? color,
  }) {
    return text(
      onPressed: onPressed,
      child: child,
      size: ButtonSize.large,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
      color: color,
    );
  }

  /// Create a small text button
  static Widget textSmall({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    IconData? icon,
    Color? color,
  }) {
    return text(
      onPressed: onPressed,
      child: child,
      size: ButtonSize.small,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      icon: icon,
      color: color,
    );
  }

  /// Create an icon text button
  static Widget textIcon({
    required VoidCallback? onPressed,
    required IconData icon,
    bool isLoading = false,
    bool isDisabled = false,
    Color? color,
  }) {
    return text(
      onPressed: onPressed,
      child: const SizedBox.shrink(),
      size: ButtonSize.icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      color: color,
    );
  }
}
