import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../domain/entities/mind_map.dart';
import '../../domain/repositories/mind_map_repository.dart';

class HomeController extends GetxController {
  final MindMapRepository _mindMapRepository = Get.find();

  // Reactive variables
  final isLoading = false.obs;
  final currentMindMap = Rxn<MindMap>();
  final savedMaps = <MindMap>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedMaps();
    _setupPostMessageListener();
  }

  // Load saved mind maps
  Future<void> loadSavedMaps() async {
    try {
      isLoading.value = true;
      final maps = await _mindMapRepository.getAllMindMaps();
      savedMaps.assignAll(maps);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load saved maps: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Save current mind map
  Future<void> saveMindMap(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      final mindMap = MindMap.create(
        title: 'Mind Map ${DateTime.now().toString().substring(0, 16)}',
        data: data.toString(),
        description: 'Auto-saved mind map',
      );

      await _mindMapRepository.saveMindMap(mindMap);
      savedMaps.add(mindMap);
      currentMindMap.value = mindMap;

      Get.snackbar(
        'Success',
        'Mind map saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save mind map: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete mind map
  Future<void> deleteMindMap(String id) async {
    try {
      await _mindMapRepository.deleteMindMap(id);
      savedMaps.removeWhere((map) => map.id == id);

      Get.snackbar(
        'Success',
        'Mind map deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete mind map: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Navigate to AI Assistant
  void openAiAssistant() {
    Get.toNamed(
      AppRoutes.AI_ASSISTANT,
      arguments: {'mindMapData': currentMindMap.value?.data},
    );
  }

  // Show saved maps dialog
  void showSavedMaps() {
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
              child: Obx(
                () => savedMaps.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey,
                            ),
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
                              title: Text(map.title),
                              subtitle: Text(
                                'Created: ${map.createdAt.toString().substring(0, 16)}',
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
                                    deleteMindMap(map.id);
                                  }
                                },
                              ),
                              onTap: () {
                                currentMindMap.value = map;
                                Get.back();
                                Get.snackbar(
                                  'Loaded',
                                  'Mind map "${map.title}" loaded',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _setupPostMessageListener() {
    html.window.onMessage.listen((event) {
      if (event.data is Map) {
        final data = event.data;
        if (data['type'] == 'excalidraw-data') {
          saveMindMap(data['payload']);
        }
      }
    });
  }
}
