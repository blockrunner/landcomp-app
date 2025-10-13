/// Attachment entity for chat messages
///
/// This entity represents an attachment (image, file, etc.) in a chat message
/// with proper metadata and data handling.
library;

import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Attachment type enumeration
enum AttachmentType {
  /// Image attachment
  image,

  /// File attachment
  file,

  /// Video attachment
  video,

  /// Audio attachment
  audio,
}

/// Attachment entity
class Attachment extends Equatable {
  /// Create an image attachment
  factory Attachment.image({
    required String id,
    required String name,
    required Uint8List data,
    required String mimeType,
    int? width,
    int? height,
    Uint8List? thumbnailData,
  }) {
    return Attachment(
      id: id,
      type: AttachmentType.image,
      name: name,
      size: data.length,
      mimeType: mimeType,
      data: data,
      width: width,
      height: height,
      thumbnailData: thumbnailData,
    );
  }

  /// Create a file attachment
  factory Attachment.file({
    required String id,
    required String name,
    required Uint8List data,
    required String mimeType,
  }) {
    return Attachment(
      id: id,
      type: AttachmentType.file,
      name: name,
      size: data.length,
      mimeType: mimeType,
      data: data,
    );
  }

  /// Create attachment from URL
  factory Attachment.fromUrl({
    required String id,
    required AttachmentType type,
    required String name,
    required String url,
    required String mimeType,
    int? size,
    int? width,
    int? height,
  }) {
    return Attachment(
      id: id,
      type: type,
      name: name,
      size: size ?? 0,
      mimeType: mimeType,
      url: url,
      width: width,
      height: height,
    );
  }

  /// Create attachment from JSON
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      type: AttachmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttachmentType.file,
      ),
      name: json['name'] as String,
      size: json['size'] as int,
      mimeType: json['mimeType'] as String,
      data: json['data'] != null
          ? Uint8List.fromList((json['data'] as List).cast<int>())
          : null,
      url: json['url'] as String?,
      thumbnailData: json['thumbnailData'] != null
          ? Uint8List.fromList((json['thumbnailData'] as List).cast<int>())
          : null,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  /// Creates an attachment
  const Attachment({
    required this.id,
    required this.type,
    required this.name,
    required this.size,
    required this.mimeType,
    this.data,
    this.url,
    this.thumbnailData,
    this.width,
    this.height,
  });

  /// Unique identifier for the attachment
  final String id;

  /// Type of the attachment
  final AttachmentType type;

  /// Name of the attachment
  final String name;

  /// Size of the attachment in bytes
  final int size;

  /// MIME type of the attachment
  final String mimeType;

  /// Binary data of the attachment (for local storage)
  final Uint8List? data;

  /// URL of the attachment (for remote storage)
  final String? url;

  /// Thumbnail data for images
  final Uint8List? thumbnailData;

  /// Width of the attachment (for images/videos)
  final int? width;

  /// Height of the attachment (for images/videos)
  final int? height;

  /// Copy attachment with new values
  Attachment copyWith({
    String? id,
    AttachmentType? type,
    String? name,
    int? size,
    String? mimeType,
    Uint8List? data,
    String? url,
    Uint8List? thumbnailData,
    int? width,
    int? height,
  }) {
    return Attachment(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      data: data ?? this.data,
      url: url ?? this.url,
      thumbnailData: thumbnailData ?? this.thumbnailData,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Convert attachment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'size': size,
      'mimeType': mimeType,
      'data': data?.toList(),
      'url': url,
      'thumbnailData': thumbnailData?.toList(),
      'width': width,
      'height': height,
    };
  }

  /// Check if attachment is an image
  bool get isImage => type == AttachmentType.image;

  /// Check if attachment has data
  bool get hasData => data != null && data!.isNotEmpty;

  /// Check if attachment has URL
  bool get hasUrl => url != null && url!.isNotEmpty;

  /// Get display size as string
  String get displaySize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [
    id,
    type,
    name,
    size,
    mimeType,
    data,
    url,
    thumbnailData,
    width,
    height,
  ];

  @override
  String toString() {
    return 'Attachment(id: $id, type: $type, name: $name, size: $size, mimeType: $mimeType)';
  }
}
