import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ai_assisstant_screen.dart';
import 'core/services/ai_service.dart';
import 'core/services/storage_service.dart';
import 'data/repositories/ai_repository_impl.dart';
import 'data/repositories/mind_map_repository_impl.dart';
import 'domain/repositories/ai_repository.dart';
import 'domain/repositories/mind_map_repository.dart';
import 'mind_map_model.dart';
import 'presentation/controllers/home_controller.dart';

// Global navigator key for navigation outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupListener() {
  html.window.onMessage.listen((event) {
    print("Received postMessage: ${event.data.runtimeType} - ${event.data}");
    try {
      final data = event.data;
      if (data != null && data['type'] == 'excalidraw-data') {
        print("Got JSON from Excalidraw: ${data['payload']}");
        print("From: ${data['from']}");

        // Save to local storage
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final mapData = {
          'id': timestamp.toString(),
          'payload': data['payload'].toString(),
          'from': data['from'],
          'created_at': timestamp,
          'title': 'Mind Map ${DateTime.now().toString().substring(0, 16)}',
        };

        html.window.localStorage['excalidraw-data-$timestamp'] = mapData
            .toString();

        // Store in a list for easy retrieval
        final existingMaps = html.window.localStorage['excalidraw-maps'] ?? '';
        final mapsList = existingMaps.isEmpty
            ? <String>[]
            : existingMaps.split(',');
        mapsList.add(timestamp.toString());
        html.window.localStorage['excalidraw-maps'] = mapsList.join(',');

        print("Mind map saved with ID: $timestamp");

        // Save to backend
        _saveToBackend(mapData);

        // If from == "home", navigate to AI Assistant screen with mapData
        if (data['from'] == "home") {
          print(data['from'] == "home");
          // Use GetX navigation
          Get.to(
            () => AIAssistantScreen(savedMaps: [mapData]),
            transition: Transition.rightToLeft,
          );
        } else {
          print("nav error");
        }
      }
    } catch (e) {
      print("Error processing message: $e");
    }
  });
}

// Backend persistence (Firebase/Supabase placeholder)
Future<void> _saveToBackend(Map<String, dynamic> mapData) async {
  try {
    // TODO: Implement Firebase/Supabase saving
    print("TODO: Save to backend - ${mapData['id']}");

    // For now, just log the structure we'd send
    print(
      "Would save: ${mapData['title']} with ${mapData['payload'].toString().length} characters",
    );
  } catch (e) {
    print("Backend save error: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup message listener
  setupListener();

  // Register iframe view
  ui.platformViewRegistry.registerViewFactory(
    'excalidraw-iframe',
    (int viewId) => html.IFrameElement()
      ..src = 'http://localhost:3000'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%',
  );

  // Initialize services
  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  // Initialize core services before app starts
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => AiService().init());

  // Repositories
  Get.lazyPut<MindMapRepository>(() => MindMapRepositoryImpl(), fenix: true);
  Get.lazyPut<AiRepository>(() => AiRepositoryImpl(), fenix: true);

  // Controllers
  Get.lazyPut<HomeController>(() => HomeController());

  print('All services started...');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mind Map AI',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const DrawIoScreen(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
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
  List<Map<String, dynamic>> savedMaps = [];
  String? selectedMapId;

  @override
  void initState() {
    super.initState();
    _loadSavedMaps();
  }

  // Load all saved maps from local storage
  void _loadSavedMaps() {
    try {
      final mapsString = html.window.localStorage['excalidraw-maps'] ?? '';
      if (mapsString.isNotEmpty) {
        final mapIds = mapsString.split(',').where((id) => id.isNotEmpty);
        savedMaps.clear();

        for (final id in mapIds) {
          final mapData = html.window.localStorage['excalidraw-data-$id'];
          if (mapData != null) {
            // Parse the stored map data
            savedMaps.add({
              'id': id,
              'title':
                  'Mind Map ${DateTime.fromMillisecondsSinceEpoch(int.parse(id)).toString().substring(0, 16)}',
              'created_at': int.parse(id),
            });
          }
        }

        savedMaps.sort((a, b) => b['created_at'].compareTo(a['created_at']));
        setState(() {});
      }
    } catch (e) {
      print("Error loading saved maps: $e");
    }
  }

  Future<void> _saveMindMap() async {
    await mindMap.saveToLocal(localKey);
    if (mounted) {
      // Use GetX snackbar
      Get.snackbar(
        'Success',
        'Mind map saved locally.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadMindMap() async {
    final loaded = await MindMapGraph.loadFromLocal(localKey);
    if (loaded != null) {
      setState(() {
        mindMap = loaded;
      });
      if (mounted) {
        Get.snackbar(
          'Success',
          'Mind map loaded from local storage.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } else {
      if (mounted) {
        Get.snackbar(
          'Info',
          'No mind map found in local storage.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }
  }

  void _exportJson() {
    final jsonStr = mindMap.exportToJson();
    Get.dialog(
      AlertDialog(
        title: const Text('Exported JSON'),
        content: SingleChildScrollView(child: Text(jsonStr)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _importJson() async {
    final controller = TextEditingController();
    await Get.dialog(
      AlertDialog(
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
                Get.back();
                Get.snackbar(
                  'Success',
                  'Mind map imported.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Invalid JSON.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Import'),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _exportGraphML() {
    final graphML = mindMap.exportToGraphML();
    Get.dialog(
      AlertDialog(
        title: const Text('Exported GraphML'),
        content: SingleChildScrollView(child: Text(graphML)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  // Show saved maps dialog
  void _showSavedMaps() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Mind Maps',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: savedMaps.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No saved maps found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: savedMaps.length,
                      itemBuilder: (context, index) {
                        final map = savedMaps[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.account_tree,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(map['title']),
                            subtitle: Text(
                              'Created: ${DateTime.fromMillisecondsSinceEpoch(map['created_at']).toString().substring(0, 16)}',
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteMap(map['id']);
                                }
                              },
                            ),
                            onTap: () => _loadMapById(map['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _deleteMap(String mapId) {
    html.window.localStorage.remove('excalidraw-data-$mapId');
    _loadSavedMaps();
    Get.back(); // Close bottom sheet
    Get.snackbar(
      'Deleted',
      'Mind map deleted successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _loadMapById(String mapId) {
    final mapData = html.window.localStorage['excalidraw-data-$mapId'];
    if (mapData != null) {
      print("Loading map: $mapId");
      // TODO: Load map data into Excalidraw
      Get.back(); // Close bottom sheet
      Get.snackbar(
        'Loaded',
        'Mind map loaded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Navigate to AI Assistant screen
  void _showAIChat() {
    Get.to(
      () => AIAssistantScreen(savedMaps: savedMaps),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mind Map AI - Excalidraw Integration",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
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
            icon: const Icon(Icons.storage),
            tooltip: 'Saved Maps',
            onPressed: _showSavedMaps,
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy),
            tooltip: 'AI Assistant',
            onPressed: _showAIChat,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export_json':
                  _exportJson();
                  break;
                case 'import_json':
                  _importJson();
                  break;
                case 'export_graphml':
                  _exportGraphML();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_json',
                child: Row(
                  children: [
                    Icon(Icons.import_export),
                    SizedBox(width: 8),
                    Text('Export JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_json',
                child: Row(
                  children: [
                    Icon(Icons.input),
                    SizedBox(width: 8),
                    Text('Import JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_graphml',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Export GraphML'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Use the embedded Excalidraw editor below to create mind maps and diagrams. "
                    "Saved maps: ${savedMaps.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAIChat,
                  icon: const Icon(Icons.psychology),
                  label: const Text('AI Assistant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: const HtmlElementView(viewType: 'excalidraw-iframe')),
        ],
      ),
    );
  }
}
