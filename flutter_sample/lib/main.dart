import 'dart:async'; // for Timer
import 'dart:html' as html;
import 'dart:ui_web' as ui; // this exposes platformViewRegistry

import 'package:flutter/material.dart';
import 'package:flutter_sample/ai_assisstant_screen.dart';
import 'package:flutter_sample/toolbar_screen.dart';

import 'mind_map_model.dart';

// Global callback for refreshing maps list
void Function()? refreshMapsCallback;

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

        // Show success snackbar if callback is available
        globalSnackbarMethod?.call(
          'Auto-saved: Mind map saved from Excalidraw',
          backgroundColor: Colors.blue,
        );

        // Refresh the maps list in UI
        if (refreshMapsCallback != null) {
          print("Calling refresh callback...");
          refreshMapsCallback!();
        } else {
          print("No refresh callback set!");
        }

        // TODO: Save to Firebase/Supabase
        _saveToBackend(mapData);

        // If from == "home", navigate to AI Assistant screen with mapData
        if (data['from'] == "home") {
          print(data['from'] == "home");
          // Use navigatorKey to access context outside widget tree
          final navigator = navigatorKey.currentState;
          if (navigator != null) {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => AIAssistantScreen(savedMaps: [mapData]),
              ),
            );
          }
        } else {
          print("nav error");
        }
      }
    } catch (e) {
      print("Error processing message: $e");
    }
  });
}

// Add this global key at the top of your file (outside any class):
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global callback for UI updates
VoidCallback? onMapsUpdated;

// Global reference to the current widget's snackbar method
Function(String, {Color? backgroundColor})? globalSnackbarMethod;

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

void main() {
  setupListener();
  // Register an iframe as a view
  // ignore: undefined_prefixed_name
  // ...existing code...
  ui.platformViewRegistry.registerViewFactory(
    'excalidraw-iframe',
    (int viewId) => html.IFrameElement()
      ..src = 'http://localhost:3000'
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const DrawIoScreen(),
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
  Timer? _refreshTimer;
  bool _isSnackBarVisible = false;

  // Helper method to show SnackBar with overlay management
  void _showSnackBarWithOverlay(String message, {Color? backgroundColor}) {
    print('SnackBar called with message: $message');
    if (!mounted) return;

    // Show overlay
    setState(() {
      _isSnackBarVisible = true;
      print('✅ Set _isSnackBarVisible = true');
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'CLOSE',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        )
        .closed
        .then((_) {
          // Hide overlay when SnackBar is dismissed
          if (mounted) {
            setState(() {
              _isSnackBarVisible = false;
              print('❌ Set _isSnackBarVisible = false');
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedMaps();

    // Set up callback for refreshing maps when saved from Excalidraw
    refreshMapsCallback = () {
      print("🔄 Refresh callback triggered from Excalidraw save!");
      _loadSavedMaps();
    };

    // Set up global snackbar method
    globalSnackbarMethod = (String message, {Color? backgroundColor}) {
      if (mounted) {
        _showSnackBarWithOverlay(message, backgroundColor: backgroundColor);
      }
    };

    // Set up periodic refresh every 3 seconds to catch any missed updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final currentCount = savedMaps.length;
      _loadSavedMaps();
      if (savedMaps.length != currentCount) {
        print("📊 Map count changed: ${savedMaps.length} (was $currentCount)");
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    refreshMapsCallback = null;
    globalSnackbarMethod = null;
    super.dispose();
  }

  // Load all saved maps from local storage
  void _loadSavedMaps() {
    try {
      print("Loading saved maps...");
      final mapsString = html.window.localStorage['excalidraw-maps'] ?? '';
      print("Maps string from storage: '$mapsString'");

      if (mapsString.isNotEmpty) {
        final mapIds = mapsString.split(',').where((id) => id.isNotEmpty);
        print("Found ${mapIds.length} map IDs: ${mapIds.toList()}");
        savedMaps.clear();

        for (final id in mapIds) {
          final mapData = html.window.localStorage['excalidraw-data-$id'];
          print("Loading map $id: ${mapData != null ? 'found' : 'not found'}");
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
        print("Loaded ${savedMaps.length} maps successfully");
        if (mounted) {
          setState(() {});
        }
      } else {
        print("No maps found in storage");
        savedMaps.clear();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print("Error loading saved maps: $e");
    }
  }

  Future<void> _saveMindMap() async {
    await mindMap.saveToLocal(localKey);

    // Also save in the same format as Excalidraw auto-save for consistency
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final mapData = {
      'id': timestamp.toString(),
      'payload': mindMap.exportToJson(),
      'from': 'manual_save',
      'created_at': timestamp,
      'title': 'Manual Save ${DateTime.now().toString().substring(0, 16)}',
    };

    // Save to the excalidraw format so it appears in the list
    html.window.localStorage['excalidraw-data-$timestamp'] = mapData.toString();

    // Add to the maps list
    final existingMaps = html.window.localStorage['excalidraw-maps'] ?? '';
    final mapsList = existingMaps.isEmpty
        ? <String>[]
        : existingMaps.split(',');
    mapsList.add(timestamp.toString());
    html.window.localStorage['excalidraw-maps'] = mapsList.join(',');

    // Refresh the saved maps list
    _loadSavedMaps();

    if (mounted) {
      // Use SnackBar with iframe pointer event management
      _showSnackBarWithOverlay(
        'Success: Mind map saved locally with ID: $timestamp',
        backgroundColor: Colors.green,
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
        _showSnackBarWithOverlay(
          'Success: Mind map loaded from local storage',
          backgroundColor: Colors.green,
        );
      }
    } else {
      if (mounted) {
        _showSnackBarWithOverlay(
          'Info: No mind map found in local storage',
          backgroundColor: Colors.orange,
        );
      }
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
                if (mounted) {
                  _showSnackBarWithOverlay(
                    'Success: Mind map imported successfully',
                    backgroundColor: Colors.green,
                  );
                }
              } catch (e) {
                if (mounted) {
                  _showSnackBarWithOverlay(
                    'Error: Invalid JSON format',
                    backgroundColor: Colors.red,
                  );
                }
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

  // Show saved maps dialog
  void _showSavedMaps() {
    // Refresh the maps list every time the dialog is opened
    _loadSavedMaps();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.storage, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Saved Mind Maps (${savedMaps.length})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: savedMaps.isEmpty
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No saved maps found'),
                    SizedBox(height: 8),
                    Text(
                      'Create a diagram in Excalidraw and click the export button to save it.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: savedMaps.length,
                  itemBuilder: (context, index) {
                    final map = savedMaps[index];
                    final createdAt = DateTime.fromMillisecondsSinceEpoch(
                      map['created_at'],
                    );
                    final timeAgo = _getTimeAgo(createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.account_tree, color: Colors.white),
                        ),
                        title: Text(map['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Created: ${createdAt.toString().substring(0, 16)}',
                            ),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'load',
                              child: Row(
                                children: [
                                  Icon(Icons.open_in_new, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Load'),
                                ],
                              ),
                            ),
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
                            } else if (value == 'load') {
                              _loadMapById(map['id']);
                            }
                          },
                        ),
                        onTap: () => _loadMapById(map['id']),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _loadSavedMaps(); // Refresh the list
              Navigator.pop(ctx);
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  void _deleteMap(String mapId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mind Map'),
        content: const Text(
          'Are you sure you want to delete this mind map? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              html.window.localStorage.remove('excalidraw-data-$mapId');

              // Remove from the maps list
              final existingMaps =
                  html.window.localStorage['excalidraw-maps'] ?? '';
              final mapsList = existingMaps
                  .split(',')
                  .where((id) => id != mapId);
              html.window.localStorage['excalidraw-maps'] = mapsList.join(',');

              _loadSavedMaps();
              Navigator.pop(ctx); // Close confirmation dialog
              Navigator.pop(context); // Close saved maps dialog

              // Show success message
              _showSnackBarWithOverlay(
                'Success: Mind map deleted successfully',
                backgroundColor: Colors.orange,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _loadMapById(String mapId) {
    final mapData = html.window.localStorage['excalidraw-data-$mapId'];
    if (mapData != null) {
      print("Loading map: $mapId");
      print("Map data: $mapData");

      // TODO: Send the map data to Excalidraw iframe
      // For now, we'll just show the user what we found
      Navigator.pop(context); // Close the dialog

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Map Loaded'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Map data retrieved from storage.'),
              const SizedBox(height: 12),
              const Text(
                'Map ID:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(mapId),
              const SizedBox(height: 8),
              const Text(
                'Note: Loading into Excalidraw is not yet implemented.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Map data not found in storage.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Navigate to AI Assistant screen
  void _showAIChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIAssistantScreen(savedMaps: savedMaps),
      ),
    );
  }

  // Navigate to Toolbar screen
  void _showToolbar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToolbarScreen(
          onShowSnackBar: _showSnackBarWithOverlay,
          onLoadMaps: _loadSavedMaps,
          onShowSavedMaps: _showSavedMaps,
          onShowAIChat: _showAIChat,
          onSaveMindMap: _saveMindMap,
          onLoadMindMap: _loadMindMap,
          onExportJson: _exportJson,
          onImportJson: _importJson,
          onExportGraphML: _exportGraphML,
        ),
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
            icon: const Icon(Icons.dashboard),
            tooltip: 'Advanced Toolbar',
            onPressed: _showToolbar,
          ),
          // IconButton(
          //   icon: const Icon(Icons.bug_report),
          //   tooltip: 'Test SnackBar',
          //   onPressed: () {
          //     _showSnackBarWithOverlay(
          //       'Test SnackBar - checking overlay approach!',
          //       backgroundColor: Colors.orange,
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.save),
          //   tooltip: 'Save',
          //   onPressed: _saveMindMap,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.folder_open),
          //   tooltip: 'Load',
          //   onPressed: _loadMindMap,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.storage),
          //   tooltip: 'Saved Maps',
          //   onPressed: _showSavedMaps,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   tooltip: 'TEST SnackBar (Refresh Maps)',
          //   onPressed: () {
          //     _loadSavedMaps();
          //     _showSnackBarWithOverlay(
          //       'TEST: Maps refreshed! Iframe should be hidden now.',
          //       backgroundColor: Colors.green,
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.smart_toy),
          //   tooltip: 'AI Assistant',
          //   onPressed: _showAIChat,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.import_export),
          //   tooltip: 'Export JSON',
          //   onPressed: _exportJson,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.input),
          //   tooltip: 'Import JSON',
          //   onPressed: _importJson,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.code),
          //   tooltip: 'Export GraphML',
          //   onPressed: _exportGraphML,
          // ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Use the embedded Excalidraw editor below to create mind maps and diagrams. "
                    "Drag and drop shapes, use quick add, and keyboard shortcuts for fast editing.",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storage,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${savedMaps.length} saved',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                // _isSnackBarVisible
                //     ? Container(
                //         width: double.infinity,
                //         height: double.infinity,
                //         color: Colors.grey[100],
                //         child: Center(
                //           child: Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Icon(
                //                 Icons.info_outline,
                //                 size: 64,
                //                 color: Colors.blue[300],
                //               ),
                //               const SizedBox(height: 16),
                //               Text(
                //                 'Excalidraw Temporarily Hidden',
                //                 style: TextStyle(
                //                   fontSize: 18,
                //                   fontWeight: FontWeight.bold,
                //                   color: Colors.grey[700],
                //                 ),
                //               ),
                //               const SizedBox(height: 8),
                //               Text(
                //                 'Please respond to the notification above',
                //                 style: TextStyle(
                //                   fontSize: 14,
                //                   color: Colors.grey[600],
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       )
                //     :
                const HtmlElementView(viewType: 'excalidraw-iframe'),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showSnackBarWithOverlay(
      //       'TEST: This should replace the iframe!',
      //       backgroundColor: Colors.green,
      //     );
      //   },
      //   backgroundColor: Colors.red,
      //   child: const Icon(Icons.science, color: Colors.white),
      //   tooltip: 'Test SnackBar Replacement',
      // ),
    );
  }
}
