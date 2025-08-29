import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Mind Maps
  Future<void> saveMindMaps(List<String> maps) async {
    await _prefs.setStringList(StorageKeys.mindMaps, maps);
  }

  List<String> getMindMaps() {
    return _prefs.getStringList(StorageKeys.mindMaps) ?? [];
  }

  // Chat History
  Future<void> saveChatHistory(List<String> messages) async {
    await _prefs.setStringList(StorageKeys.chatHistory, messages);
  }

  List<String> getChatHistory() {
    return _prefs.getStringList(StorageKeys.chatHistory) ?? [];
  }

  // Generic methods
  Future<void> write(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  T? read<T>(String key) {
    return _prefs.get(key) as T?;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
}
