/// New project dialog widget
///
/// This widget displays a dialog for creating a new project
/// with optional custom title input.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:landcomp_app/core/localization/language_provider.dart';

/// New project dialog widget
class NewProjectDialog extends StatefulWidget {
  /// Creates a new project dialog
  const NewProjectDialog({required this.onProjectCreated, super.key});

  /// Callback when a project is created
  final void Function(String? title) onProjectCreated;

  @override
  State<NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _controller = TextEditingController();
  bool _isCreating = false;

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
          title: Text(languageProvider.getString('newProjectDialog')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageProvider.getString('enterProjectTitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: languageProvider.getString('projectTitle'),
                  hintText: languageProvider.getString('projectTitleHint'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.folder_outlined),
                ),
                autofocus: true,
                enabled: !_isCreating,
                onSubmitted: (_) => _createProject(languageProvider),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
              child: Text(languageProvider.getString('cancel')),
            ),
            ElevatedButton(
              onPressed: _isCreating
                  ? null
                  : () => _createProject(languageProvider),
              child: _isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(languageProvider.getString('createProject')),
            ),
          ],
        );
      },
    );
  }

  /// Creates a new project
  void _createProject(LanguageProvider languageProvider) {
    final title = _controller.text.trim();

    setState(() {
      _isCreating = true;
    });

    // Simulate a brief delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onProjectCreated(title.isEmpty ? null : title);
    });
  }
}
