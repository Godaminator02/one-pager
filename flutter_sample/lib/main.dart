import 'dart:html' as html;
import 'dart:ui_web' as ui; // this exposes platformViewRegistry

import 'package:flutter/material.dart';

import 'mind_map_model.dart';

void setupListener() {
  html.window.onMessage.listen((event) {
    print("Received postMessage: ${event.data.runtimeType} - ${event.data}");
    try {
      final data = event.data;
      if (data != null && data['type'] == 'excalidraw-data') {
        print("Got JSON from Excalidraw: ${data['payload']}");
        // Save to local storage
        html.window.localStorage['excalidraw-data'] = data['payload']
            .toString();
      }
    } catch (e) {
      print("Error processing message: $e");
    }
  });
}

void main() {
  setupListener();
  // Register an iframe as a view
  // ignore: undefined_prefixed_name
  // ...existing code...
  ui.platformViewRegistry.registerViewFactory(
    'excalidraw-iframe',
    (int viewId) => html.IFrameElement()
      ..src = 'http://localhost:3001'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%',
  );
  // ...existing code...

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DrawIoScreen(),
    );
  }
}

class DrawIoScreen extends StatefulWidget {
  const DrawIoScreen({super.key});

  @override
  State<DrawIoScreen> createState() => _DrawIoScreenState();
}

class _DrawIoScreenState extends State<DrawIoScreen> {
  MindMapGraph mindMap = MindMapGraph();
  final String localKey = 'my_mind_map';

  Future<void> _saveMindMap() async {
    await mindMap.saveToLocal(localKey);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mind map saved locally.')));
  }

  Future<void> _loadMindMap() async {
    final loaded = await MindMapGraph.loadFromLocal(localKey);
    if (loaded != null) {
      setState(() {
        mindMap = loaded;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mind map loaded from local storage.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No mind map found in local storage.')),
      );
    }
  }

  void _exportJson() {
    final jsonStr = mindMap.exportToJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exported JSON'),
        content: SingleChildScrollView(child: Text(jsonStr)),
        actions: [
          TextButton(
            onPressed: () {
              // Navigator.pop(context);
              Navigator.pop(ctx);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importJson() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import JSON'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(hintText: 'Paste JSON here'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              try {
                final imported = MindMapGraph.importFromJson(controller.text);
                setState(() {
                  mindMap = imported;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mind map imported.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Invalid JSON.')));
              }
            },
            child: const Text('Import'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportGraphML() {
    final graphML = mindMap.exportToGraphML();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exported GraphML'),
        content: SingleChildScrollView(child: Text(graphML)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escalidraw.io in Flutter Web"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _saveMindMap,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load',
            onPressed: _loadMindMap,
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            tooltip: 'Export JSON',
            onPressed: _exportJson,
          ),
          IconButton(
            icon: const Icon(Icons.input),
            tooltip: 'Import JSON',
            onPressed: _importJson,
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Export GraphML',
            onPressed: _exportGraphML,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(8),
            child: const Text(
              "Use the embedded Excalidraw editor below to create mind maps and diagrams. "
              "Drag and drop shapes, use quick add, and keyboard shortcuts for fast editing.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          const Expanded(child: HtmlElementView(viewType: 'excalidraw-iframe')),
        ],
      ),
    );
  }
}
