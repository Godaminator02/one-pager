import 'package:uuid/uuid.dart';

enum MessageType { user, ai, system }

class AiMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final bool isTyping;

  const AiMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.metadata,
    this.isTyping = false,
  });

  factory AiMessage.user(String content) {
    return AiMessage(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  factory AiMessage.ai(String content, {Map<String, dynamic>? metadata}) {
    return AiMessage(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  factory AiMessage.system(String content) {
    return AiMessage(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
    );
  }

  AiMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isTyping,
  }) {
    return AiMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
      'isTyping': isTyping,
    };
  }

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      metadata: json['metadata'],
      isTyping: json['isTyping'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AiMessage(id: $id, type: $type, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}
