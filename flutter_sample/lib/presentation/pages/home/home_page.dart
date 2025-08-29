import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Register the iframe view type
    ui.platformViewRegistry.registerViewFactory('excalidraw-iframe', (
      int viewId,
    ) {
      final iframe = html.IFrameElement()
        ..src = 'assets/excalidraw/index.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mind Map AI',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
            icon: const Icon(Icons.folder_outlined),
            onPressed: controller.showSavedMaps,
            tooltip: 'Saved Maps',
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: controller.openAiAssistant,
            tooltip: 'AI Assistant',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Excalidraw iframe
          const HtmlElementView(viewType: 'excalidraw-iframe'),

          // Loading overlay
          Obx(
            () => controller.isLoading.value
                ? Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Processing...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Floating stats card
          Positioned(
            top: 16,
            right: 16,
            child: Obx(
              () => Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_tree,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.savedMaps.length} Maps',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: controller.openAiAssistant,
            heroTag: "ai",
            backgroundColor: Colors.purple,
            child: const Icon(Icons.psychology, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: controller.showSavedMaps,
            heroTag: "saved",
            backgroundColor: Colors.blue,
            child: const Icon(Icons.folder, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
