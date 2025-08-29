import '../entities/mind_map.dart';

abstract class MindMapRepository {
  Future<List<MindMap>> getAllMindMaps();
  Future<MindMap?> getMindMapById(String id);
  Future<void> saveMindMap(MindMap mindMap);
  Future<void> deleteMindMap(String id);
  Future<void> updateMindMap(MindMap mindMap);
  Future<List<MindMap>> searchMindMaps(String query);
  Future<void> bulkDelete(List<String> ids);
  Future<int> getMindMapCount();
}
