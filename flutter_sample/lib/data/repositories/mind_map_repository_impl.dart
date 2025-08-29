import 'dart:convert';

import 'package:get/get.dart';

import '../../core/services/storage_service.dart';
import '../../domain/entities/mind_map.dart';
import '../../domain/repositories/mind_map_repository.dart';
import '../models/mind_map_model.dart';

class MindMapRepositoryImpl implements MindMapRepository {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  Future<List<MindMap>> getAllMindMaps() async {
    try {
      final mapsJson = _storageService.getMindMaps();
      return mapsJson
          .map(
            (jsonString) =>
                MindMapModel.fromJson(jsonDecode(jsonString)).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load mind maps: $e');
    }
  }

  @override
  Future<MindMap?> getMindMapById(String id) async {
    try {
      final maps = await getAllMindMaps();
      return maps.where((map) => map.id == id).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get mind map by id: $e');
    }
  }

  @override
  Future<void> saveMindMap(MindMap mindMap) async {
    try {
      final maps = await getAllMindMaps();
      final existingIndex = maps.indexWhere((map) => map.id == mindMap.id);

      if (existingIndex != -1) {
        maps[existingIndex] = mindMap;
      } else {
        maps.add(mindMap);
      }

      final mapsJson = maps
          .map((map) => jsonEncode(MindMapModel.fromEntity(map).toJson()))
          .toList();

      await _storageService.saveMindMaps(mapsJson);
    } catch (e) {
      throw Exception('Failed to save mind map: $e');
    }
  }

  @override
  Future<void> deleteMindMap(String id) async {
    try {
      final maps = await getAllMindMaps();
      maps.removeWhere((map) => map.id == id);

      final mapsJson = maps
          .map((map) => jsonEncode(MindMapModel.fromEntity(map).toJson()))
          .toList();

      await _storageService.saveMindMaps(mapsJson);
    } catch (e) {
      throw Exception('Failed to delete mind map: $e');
    }
  }

  @override
  Future<void> updateMindMap(MindMap mindMap) async {
    try {
      final updatedMindMap = mindMap.copyWith(updatedAt: DateTime.now());
      await saveMindMap(updatedMindMap);
    } catch (e) {
      throw Exception('Failed to update mind map: $e');
    }
  }

  @override
  Future<List<MindMap>> searchMindMaps(String query) async {
    try {
      final maps = await getAllMindMaps();
      return maps.where((map) {
        return map.title.toLowerCase().contains(query.toLowerCase()) ||
            map.description?.toLowerCase().contains(query.toLowerCase()) ==
                true ||
            map.tags.any(
              (tag) => tag.toLowerCase().contains(query.toLowerCase()),
            );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search mind maps: $e');
    }
  }

  @override
  Future<void> bulkDelete(List<String> ids) async {
    try {
      final maps = await getAllMindMaps();
      maps.removeWhere((map) => ids.contains(map.id));

      final mapsJson = maps
          .map((map) => jsonEncode(MindMapModel.fromEntity(map).toJson()))
          .toList();

      await _storageService.saveMindMaps(mapsJson);
    } catch (e) {
      throw Exception('Failed to bulk delete mind maps: $e');
    }
  }

  @override
  Future<int> getMindMapCount() async {
    try {
      final maps = await getAllMindMaps();
      return maps.length;
    } catch (e) {
      throw Exception('Failed to get mind map count: $e');
    }
  }
}
