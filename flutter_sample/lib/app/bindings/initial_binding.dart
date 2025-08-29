import 'package:get/get.dart';

import '../../core/services/ai_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/mind_map_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/mind_map_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<AiService>(() => AiService(), fenix: true);

    // Repositories
    Get.lazyPut<MindMapRepository>(() => MindMapRepositoryImpl(), fenix: true);
    Get.lazyPut<AiRepository>(() => AiRepositoryImpl(), fenix: true);
  }
}
