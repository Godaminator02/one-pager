import 'dart:convert';

import 'package:get/get.dart';

import '../../core/services/ai_service.dart';
import '../../core/services/storage_service.dart';
import '../../domain/entities/ai_message.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiService _aiService = Get.find<AiService>();
  final StorageService _storageService = Get.find<StorageService>();

  @override
  Future<String> sendMessage(String message, {String? context}) async {
    try {
      return await _aiService.sendMessage(message, context: context);
    } catch (e) {
      throw Exception('Failed to send message to AI: $e');
    }
  }

  @override
  Future<List<AiMessage>> getChatHistory() async {
    try {
      final historyJson = _storageService.getChatHistory();
      return historyJson
          .map((jsonString) => AiMessage.fromJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load chat history: $e');
    }
  }

  @override
  Future<void> saveChatHistory(List<AiMessage> messages) async {
    try {
      final messagesJson = messages
          .map((message) => jsonEncode(message.toJson()))
          .toList();

      await _storageService.saveChatHistory(messagesJson);
    } catch (e) {
      throw Exception('Failed to save chat history: $e');
    }
  }

  @override
  Future<void> clearChatHistory() async {
    try {
      await _storageService.saveChatHistory([]);
    } catch (e) {
      throw Exception('Failed to clear chat history: $e');
    }
  }

  @override
  Future<String> analyzeMindMap(String mindMapData) async {
    try {
      return await _aiService.sendMessage(
        'Please analyze this mind map and provide insights',
        context: mindMapData,
      );
    } catch (e) {
      throw Exception('Failed to analyze mind map: $e');
    }
  }

  @override
  Future<List<String>> generateSuggestions(String mindMapData) async {
    try {
      await _aiService.sendMessage(
        'Generate 5 improvement suggestions for this mind map',
        context: mindMapData,
      );

      // Parse the response and extract suggestions
      // For now, return mock suggestions
      return [
        'Add more visual elements with colors and icons',
        'Create cross-connections between related concepts',
        'Group similar ideas into clusters',
        'Add priority levels to different branches',
        'Include actionable items and next steps',
      ];
    } catch (e) {
      throw Exception('Failed to generate suggestions: $e');
    }
  }
}
