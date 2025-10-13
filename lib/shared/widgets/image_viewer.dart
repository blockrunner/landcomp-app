/// Full-screen image viewer with navigation
///
/// This widget provides a full-screen image viewing experience
/// with swipe navigation between multiple images.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landcomp_app/features/chat/domain/entities/attachment.dart';
import 'package:landcomp_app/core/localization/language_provider.dart';

/// Full-screen image viewer
class ImageViewer extends StatefulWidget {
  /// Creates an image viewer
  const ImageViewer({
    required this.attachments,
    required this.initialIndex,
    super.key,
    this.title,
  });

  /// List of image attachments to display
  final List<Attachment> attachments;

  /// Initial image index to show
  final int initialIndex;

  /// Optional title for the viewer
  final String? title;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Remove back button
          title: Text(
            languageProvider.formatImageCounter(
              _currentIndex,
              widget.attachments.length,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [_buildCloseButton()],
        ),
        body: Stack(
          children: [
            // Clickable zones for navigation
            _buildClickableZones(),

            // Main image viewer
            Center(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.attachments.length,
                itemBuilder: (context, index) {
                  final attachment = widget.attachments[index];
                  return _buildImageView(attachment);
                },
              ),
            ),

            // Side navigation arrows
            if (widget.attachments.length > 1) ..._buildSideArrows(),

            // Image info overlay
            Positioned(bottom: 0, left: 0, right: 0, child: _buildImageInfo()),
          ],
        ),
      ),
    );
  }

  /// Build individual image view
  Widget _buildImageView(Attachment attachment) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: attachment.hasData
              ? Image.memory(
                  attachment.data!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageError(attachment.name);
                  },
                )
              : _buildImageError(attachment.name),
        ),
      ),
    );
  }

  /// Build clickable zones for navigation
  Widget _buildClickableZones() {
    return Row(
      children: [
        // Left zone (30%)
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _currentIndex > 0 ? _previousImage : null,
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
            ),
          ),
        ),
        // Center zone (40%) - no action
        Expanded(
          flex: 4,
          child: Container(color: Colors.transparent, height: double.infinity),
        ),
        // Right zone (30%)
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _currentIndex < widget.attachments.length - 1
                ? _nextImage
                : null,
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }

  /// Build close button with hover effect
  Widget _buildCloseButton() {
    return _HoverButton(
      onTap: () => Navigator.of(context).pop(),
      child: const Icon(Icons.close, color: Colors.white),
    );
  }

  /// Build side navigation arrows
  List<Widget> _buildSideArrows() {
    return [
      // Left arrow
      if (_currentIndex > 0)
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: _HoverButton(
              onTap: _previousImage,
              child: SizedBox(
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      // Right arrow
      if (_currentIndex < widget.attachments.length - 1)
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: _HoverButton(
              onTap: _nextImage,
              child: SizedBox(
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
    ];
  }

  /// Build image information overlay
  Widget _buildImageInfo() {
    final attachment = widget.attachments[_currentIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            attachment.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${attachment.displaySize} • ${attachment.mimeType}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (attachment.width != null && attachment.height != null) ...[
            const SizedBox(height: 2),
            Text(
              '${attachment.width} × ${attachment.height}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Build error widget for failed image loading
  Widget _buildImageError(String imageName) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) => Text(
              languageProvider.getString('failedToLoadImage'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            imageName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Navigate to previous image
  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to next image
  void _nextImage() {
    if (_currentIndex < widget.attachments.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

/// Show image viewer dialog
Future<void> showImageViewer({
  required BuildContext context,
  required List<Attachment> attachments,
  required int initialIndex,
  String? title,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ImageViewer(
        attachments: attachments,
        initialIndex: initialIndex,
        title: title,
      ),
      fullscreenDialog: true,
    ),
  );
}

/// Button with hover effect
class _HoverButton extends StatefulWidget {
  const _HoverButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
