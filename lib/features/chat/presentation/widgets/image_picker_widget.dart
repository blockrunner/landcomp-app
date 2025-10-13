/// Image picker widget for selecting and previewing images
///
/// This widget allows users to select up to 5 images and preview them
/// before sending to the AI service.
library;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:landcomp_app/core/localization/language_provider.dart';

/// Image picker widget
class ImagePickerWidget extends StatefulWidget {
  /// Creates an image picker widget
  const ImagePickerWidget({
    required this.onImagesSelected,
    super.key,
    this.maxImages = 5,
  });

  /// Callback when images are selected
  final void Function(List<Uint8List>) onImagesSelected;

  /// Maximum number of images allowed
  final int maxImages;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final List<Uint8List> _selectedImages = [];
  bool _isLoading = false;

  /// Pick images from device
  Future<void> _pickImages() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final newImages = <Uint8List>[];

        for (final file in result.files) {
          if (file.bytes != null) {
            // Compress image if it's too large
            var compressedImage = await _compressImage(file.bytes!);
            newImages.add(compressedImage);
          }
        }

        // Limit to maxImages
        final totalImages = _selectedImages.length + newImages.length;
        if (totalImages > widget.maxImages) {
          final remainingSlots = widget.maxImages - _selectedImages.length;
          if (remainingSlots > 0) {
            newImages.removeRange(remainingSlots, newImages.length);
          } else {
            newImages.clear();
          }
        }

        print('📸 ImagePicker: Selected ${newImages.length} new images');
        print(
          '📸 ImagePicker: Total images: ${_selectedImages.length + newImages.length}',
        );
        print(
          '📸 ImagePicker: Image sizes: ${newImages.map((img) => img.length).toList()}',
        );

        setState(() {
          _selectedImages.addAll(newImages);
        });

        widget.onImagesSelected(_selectedImages);
        print(
          '📸 ImagePicker: Notified parent with ${_selectedImages.length} images',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.read<LanguageProvider>().getString('imageSelectionError')} $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Remove image at index
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  /// Compress image to reduce size
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      // Import image package
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize if image is too large (max width 800px)
      var resizedImage = image;
      if (image.width > 800) {
        resizedImage = img.copyResize(image, width: 800);
      }

      // Encode to JPEG with quality 70% to reduce size
      final compressedBytes = img.encodeJpg(resizedImage, quality: 70);

      print(
        '📸 Compressed image: ${imageBytes.length} -> ${compressedBytes.length} bytes',
      );
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      print('❌ Error compressing image: $e');
      return imageBytes; // Return original if compression fails
    }
  }

  /// Clear all images
  void _clearImages() {
    setState(() {
      _selectedImages.clear();
    });
    widget.onImagesSelected(_selectedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected images preview
        if (_selectedImages.isNotEmpty) ...[
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Image picker button
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImages,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) => Text(
                  _selectedImages.isEmpty
                      ? languageProvider.getString('selectPhotos')
                      : languageProvider.formatAddPhotosText(
                          _selectedImages.length,
                          widget.maxImages,
                        ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: _clearImages,
                child: Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) =>
                      Text(languageProvider.getString('clear')),
                ),
              ),
            ],
          ],
        ),

        // Info text
        if (_selectedImages.isEmpty)
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) => Text(
              languageProvider.formatCanSelectUpTo(widget.maxImages),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
