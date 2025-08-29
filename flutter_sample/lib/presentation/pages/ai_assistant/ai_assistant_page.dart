import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/ai_assistant_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/typing_indicator.dart';

class AiAssistantPage extends GetView<AiAssistantController> {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'analyze':
                  controller.analyzeMindMap();
                  break;
                case 'suggestions':
                  controller.getSuggestions();
                  break;
                case 'clear':
                  controller.clearChat();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'analyze',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Analyze Mind Map'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'suggestions',
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Get Suggestions'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: Column(
          children: [
            // Quick actions bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      'Analyze',
                      Icons.analytics,
                      Colors.blue,
                      () => controller.analyzeMindMap(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionButton(
                      'Suggestions',
                      Icons.lightbulb,
                      Colors.orange,
                      () => controller.getSuggestions(),
                    ),
                  ),
                ],
              ),
            ),

            // Chat messages area
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: controller.messages[index]);
                  },
                ),
              ),
            ),

            // Typing indicator
            Obx(
              () => controller.isTyping.value
                  ? const TypingIndicator()
                  : const SizedBox.shrink(),
            ),

            // Message input
            MessageInput(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
