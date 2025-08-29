import '../../domain/entities/mind_map.dart';

class MindMapModel extends MindMap {
  const MindMapModel({
    required super.id,
    required super.title,
    required super.data,
    required super.createdAt,
    required super.updatedAt,
    super.tags,
    super.description,
    super.version,
  });

  factory MindMapModel.fromEntity(MindMap mindMap) {
    return MindMapModel(
      id: mindMap.id,
      title: mindMap.title,
      data: mindMap.data,
      createdAt: mindMap.createdAt,
      updatedAt: mindMap.updatedAt,
      tags: mindMap.tags,
      description: mindMap.description,
      version: mindMap.version,
    );
  }

  factory MindMapModel.fromJson(Map<String, dynamic> json) {
    return MindMapModel(
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

  MindMap toEntity() {
    return MindMap(
      id: id,
      title: title,
      data: data,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      description: description,
      version: version,
    );
  }
}
