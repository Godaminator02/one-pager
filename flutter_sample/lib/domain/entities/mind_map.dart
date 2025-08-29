import 'package:uuid/uuid.dart';

class MindMap {
  final String id;
  final String title;
  final String data;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? description;
  final int version;

  const MindMap({
    required this.id,
    required this.title,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.description,
    this.version = 1,
  });

  factory MindMap.create({
    required String title,
    required String data,
    List<String>? tags,
    String? description,
  }) {
    final now = DateTime.now();
    return MindMap(
      id: const Uuid().v4(),
      title: title,
      data: data,
      createdAt: now,
      updatedAt: now,
      tags: tags ?? [],
      description: description,
    );
  }

  MindMap copyWith({
    String? id,
    String? title,
    String? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? description,
    int? version,
  }) {
    return MindMap(
      id: id ?? this.id,
      title: title ?? this.title,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'tags': tags,
      'description': description,
      'version': version,
    };
  }

  factory MindMap.fromJson(Map<String, dynamic> json) {
    return MindMap(
      id: json['id'],
      title: json['title'],
      data: json['data'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'],
      version: json['version'] ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MindMap && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MindMap(id: $id, title: $title, createdAt: $createdAt)';
  }
}
