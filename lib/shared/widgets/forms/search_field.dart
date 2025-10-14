/// Search field widget following the LandComp style guide
///
/// This widget implements a search field with search icon,
/// clear button, and autocomplete functionality.
library;

import 'package:flutter/material.dart';
import 'package:landcomp_app/core/theme/design_tokens.dart';
import 'package:landcomp_app/core/theme/spacing.dart';
import 'package:landcomp_app/core/theme/typography.dart';
import 'package:landcomp_app/shared/widgets/forms/custom_text_field.dart';

/// Search field widget
class SearchField extends StatefulWidget {
  /// Creates a search field
  const SearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Поиск растений...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.suggestions = const [],
    this.onSuggestionSelected,
    this.width,
    this.height,
    this.enabled = true,
    this.autofocus = false,
  });

  /// Text editing controller
  final TextEditingController? controller;

  /// Focus node
  final FocusNode? focusNode;

  /// Hint text
  final String hintText;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submitted callback
  final ValueChanged<String>? onSubmitted;

  /// On clear callback
  final VoidCallback? onClear;

  /// List of suggestions
  final List<String> suggestions;

  /// On suggestion selected callback
  final ValueChanged<String>? onSuggestionSelected;

  /// Field width
  final double? width;

  /// Field height
  final double? height;

  /// Whether field is enabled
  final bool enabled;

  /// Whether field should autofocus
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions =
          _focusNode.hasFocus &&
          widget.suggestions.isNotEmpty &&
          _controller.text.isNotEmpty;
    });
  }

  void _onClear() {
    _controller.clear();
    setState(() {
      _showClearButton = false;
      _showSuggestions = false;
    });
    widget.onClear?.call();
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSuggestionSelected?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _controller,
          focusNode: _focusNode,
          hintText: widget.hintText,
          prefixIcon: Icons.search,
          suffixIcon: _showClearButton ? Icons.clear : null,
          onChanged: (value) {
            setState(() {
              _showSuggestions =
                  _focusNode.hasFocus &&
                  widget.suggestions.isNotEmpty &&
                  value.isNotEmpty;
            });
            widget.onChanged?.call(value);
          },
          onSubmitted: widget.onSubmitted,
          onTap: _onClearButtonTap,
          width: widget.width,
          height: widget.height,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
        ),
        if (_showSuggestions) ...[
          const SizedBox(height: AppSpacing.xs),
          _buildSuggestionsList(),
        ],
      ],
    );
  }

  /// Handle clear button tap
  void _onClearButtonTap() {
    if (_showClearButton) {
      _onClear();
    }
  }

  /// Build suggestions list
  Widget _buildSuggestionsList() {
    final filteredSuggestions = widget.suggestions
        .where(
          (suggestion) =>
              suggestion.toLowerCase().contains(_controller.text.toLowerCase()),
        )
        .take(5)
        .toList();

    if (filteredSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: DesignTokens.shadowMedium,
      ),
      child: Column(
        children: filteredSuggestions.map((suggestion) {
          return InkWell(
            onTap: () => _onSuggestionSelected(suggestion),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: DesignTokens.iconSizeSmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
