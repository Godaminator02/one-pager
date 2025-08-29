import '../entities/ai_message.dart';

abstract class AiRepository {
  Future<String> sendMessage(String message, {String? context});
  Future<List<AiMessage>> getChatHistory();
  Future<void> saveChatHistory(List<AiMessage> messages);
  Future<void> clearChatHistory();
  Future<String> analyzeMindMap(String mindMapData);
  Future<List<String>> generateSuggestions(String mindMapData);
}
