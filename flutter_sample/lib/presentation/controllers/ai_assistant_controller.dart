import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/ai_message.dart';
import '../../domain/repositories/ai_repository.dart';

class AiAssistantController extends GetxController {
  final AiRepository _aiRepository = Get.find();

  // Reactive variables
  final messages = <AiMessage>[].obs;
  final isTyping = false.obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // Mind map data passed from previous screen
  String? mindMapData;

  @override
  void onInit() {
    super.onInit();
    mindMapData = Get.arguments?['mindMapData'];
    _loadInitialMessage();
    _loadChatHistory();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _loadInitialMessage() {
    final welcomeMessage = mindMapData != null
        ? AiMessage.ai(
            "Hello! I can see you have a mind map loaded. I'm here to help you analyze, improve, and understand your mind map better. What would you like to know about it?",
          )
        : AiMessage.ai(
            "Welcome to AI Assistant! I can help you analyze mind maps, provide insights, and suggest improvements. How can I assist you today?",
          );

    messages.add(welcomeMessage);
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await _aiRepository.getChatHistory();
      if (history.isNotEmpty) {
        messages.insertAll(0, history);
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = AiMessage.user(content);
    messages.add(userMessage);
    messageController.clear();

    // Scroll to bottom
    _scrollToBottom();

    // Show typing indicator
    isTyping.value = true;

    try {
      // Send to AI service
      final response = await _aiRepository.sendMessage(
        content,
        context: mindMapData,
      );

      // Add AI response
      final aiMessage = AiMessage.ai(response);
      messages.add(aiMessage);

      // Save chat history
      await _saveChatHistory();
    } catch (e) {
      final errorMessage = AiMessage.ai(
        "Sorry, I encountered an error while processing your request: $e\\n\\nPlease try again or rephrase your question.",
      );
      messages.add(errorMessage);
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      await _aiRepository.saveChatHistory(messages);
    } catch (e) {
      // Handle error silently
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> clearChat() async {
    try {
      await _aiRepository.clearChatHistory();
      messages.clear();
      _loadInitialMessage();

      Get.snackbar(
        'Chat Cleared',
        'Chat history has been cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear chat: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void analyzeMindMap() {
    if (mindMapData != null) {
      sendMessage(
        'Please analyze my current mind map and provide detailed insights',
      );
    } else {
      Get.snackbar(
        'No Mind Map',
        'Please load a mind map first to analyze',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void getSuggestions() {
    if (mindMapData != null) {
      sendMessage(
        'Can you provide 5 specific suggestions to improve my mind map?',
      );
    } else {
      Get.snackbar(
        'No Mind Map',
        'Please load a mind map first to get suggestions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
