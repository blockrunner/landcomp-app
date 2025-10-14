import 'package:equatable/equatable.dart';
import 'package:landcomp_app/features/chat/domain/entities/message.dart';

class Project extends Equatable {

  const Project({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.isFavorite = false,
    this.description,
    this.previewText,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final messages =
        (json['messages'] as List<dynamic>?)
            ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
            .toList() ??
        const [];
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: messages,
      isFavorite: json['isFavorite'] as bool? ?? false,
      description: json['description'] as String?,
      previewText: json['previewText'] as String?,
    );
  }
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;
  final bool isFavorite;
  final String? description;
  final String? previewText;

  Project copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    bool? isFavorite,
    String? description,
    String? previewText,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      previewText: previewText ?? this.previewText,
    );
  }

  Project addMessage(Message message) {
    final updatedMessages = List<Message>.from(messages)..add(message);
    return copyWith(messages: updatedMessages, updatedAt: DateTime.now());
  }

  Project removeMessage(String messageId) {
    final updatedMessages = messages.where((m) => m.id != messageId).toList();
    return copyWith(messages: updatedMessages, updatedAt: DateTime.now());
  }

  Project clearMessages() {
    return copyWith(messages: const [], updatedAt: DateTime.now());
  }

  Project updateTitle(String newTitle) {
    return copyWith(title: newTitle, updatedAt: DateTime.now());
  }

  Project toggleFavorite() {
    return copyWith(isFavorite: !isFavorite, updatedAt: DateTime.now());
  }

  int get messageCount => messages.length;

  String get lastModifiedRelative {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'isFavorite': isFavorite,
      'description': description,
      'previewText': previewText,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdAt,
    updatedAt,
    messages,
    isFavorite,
    description,
    previewText,
  ];

  @override
  String toString() {
    return 'Project(id: $id, title: $title, messageCount: ${messages.length})';
  }
}
