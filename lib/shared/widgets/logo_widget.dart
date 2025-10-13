/// Logo widget for LandComp application
/// 
/// This widget displays the LandComp logo with customizable size and styling.
library;

import 'package:flutter/material.dart';

/// Logo widget that displays the LandComp logo
class LogoWidget extends StatelessWidget {
  /// Creates a logo widget
  const LogoWidget({
    super.key,
    this.size = 100,
    this.showText = true,
    this.textStyle,
  });

  /// Size of the logo
  final double size;

  /// Whether to show the text below the logo
  final bool showText;

  /// Custom text style for the logo text
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.2),
            child: Image.asset(
              'assets/images/logo.jpg',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to icon if image fails to load
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(size * 0.2),
                  ),
                  child: Icon(
                    Icons.landscape,
                    size: size * 0.6,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'LandComp',
            style: textStyle ??
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ],
    );
  }
}

/// Small logo widget for app bars and compact spaces
class SmallLogoWidget extends StatelessWidget {
  /// Creates a small logo widget
  const SmallLogoWidget({
    super.key,
    this.size = 32,
  });

  /// Size of the logo
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          'assets/images/logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image fails to load
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
              child: Icon(
                Icons.landscape,
                size: size * 0.6,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
