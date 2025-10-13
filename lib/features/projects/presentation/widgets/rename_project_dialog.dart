/// Rename project dialog widget
/// 
/// This dialog allows users to rename an existing project.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/language_provider.dart';

/// Rename project dialog widget
class RenameProjectDialog extends StatefulWidget {
  /// Creates a rename project dialog
  const RenameProjectDialog({
    super.key,
    required this.currentTitle,
    required this.onRenamed,
  });

  /// Current project title
  final String currentTitle;

  /// Callback when project is renamed
  final void Function(String) onRenamed;

  @override
  State<RenameProjectDialog> createState() => _RenameProjectDialogState();
}

class _RenameProjectDialogState extends State<RenameProjectDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.currentTitle.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return AlertDialog(
          title: Text(languageProvider.getString('renameProject')),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: languageProvider.getString('projectTitle'),
                hintText: languageProvider.getString('projectTitleHint'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return languageProvider.getString('enterProjectTitle');
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleRename(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.getString('cancel')),
            ),
            FilledButton(
              onPressed: _handleRename,
              child: Text(languageProvider.getString('save')),
            ),
          ],
        );
      },
    );
  }

  void _handleRename() {
    if (_formKey.currentState!.validate()) {
      final newTitle = _controller.text.trim();
      if (newTitle != widget.currentTitle) {
        widget.onRenamed(newTitle);
      }
      Navigator.of(context).pop();
    }
  }
}

