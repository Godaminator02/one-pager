import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MindMapNode {
  final String id;
  String title;
  String description;
  List<String> tags;

  MindMapNode({
    required this.id,
    required this.title,
    this.description = '',
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'tags': tags,
  };

  static MindMapNode fromJson(Map<String, dynamic> json) => MindMapNode(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    tags: List<String>.from(json['tags'] ?? []),
  );
}

class MindMapEdge {
  final String from;
  final String to;
  String relationship;

  MindMapEdge({
    required this.from,
    required this.to,
    this.relationship = 'leads to',
  });

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'relationship': relationship,
  };

  static MindMapEdge fromJson(Map<String, dynamic> json) => MindMapEdge(
    from: json['from'],
    to: json['to'],
    relationship: json['relationship'] ?? 'leads to',
  );
}

class MindMapGraph {
  List<MindMapNode> nodes;
  List<MindMapEdge> edges;

  MindMapGraph({this.nodes = const [], this.edges = const []});

  Map<String, dynamic> toJson() => {
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'edges': edges.map((e) => e.toJson()).toList(),
  };

  static MindMapGraph fromJson(Map<String, dynamic> json) => MindMapGraph(
    nodes: (json['nodes'] as List).map((n) => MindMapNode.fromJson(n)).toList(),
    edges: (json['edges'] as List).map((e) => MindMapEdge.fromJson(e)).toList(),
  );

  // Export to JSON string
  String exportToJson() => jsonEncode(toJson());

  // Import from JSON string
  static MindMapGraph importFromJson(String jsonStr) =>
      MindMapGraph.fromJson(jsonDecode(jsonStr));

  // Save to local DB (shared_preferences)
  Future<void> saveToLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, exportToJson());
  }

  // Load from local DB (shared_preferences)
  static Future<MindMapGraph?> loadFromLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      return importFromJson(jsonStr);
    }
    return null;
  }

  // Export to GraphML (basic implementation)
  String exportToGraphML() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<graphml xmlns="http://graphml.graphdrawing.org/xmlns">');
    buffer.writeln('  <graph id="G" edgedefault="directed">');
    for (var node in nodes) {
      buffer.writeln('    <node id="${node.id}">');
      buffer.writeln('      <data key="title">${node.title}</data>');
      buffer.writeln(
        '      <data key="description">${node.description}</data>',
      );
      buffer.writeln('      <data key="tags">${node.tags.join(",")}</data>');
      buffer.writeln('    </node>');
    }
    for (var edge in edges) {
      buffer.writeln('    <edge source="${edge.from}" target="${edge.to}">');
      buffer.writeln(
        '      <data key="relationship">${edge.relationship}</data>',
      );
      buffer.writeln('    </edge>');
    }
    buffer.writeln('  </graph>');
    buffer.writeln('</graphml>');
    return buffer.toString();
  }
}
