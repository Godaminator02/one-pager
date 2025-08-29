import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/services/ai_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  // Initialize core services before app starts
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => AiService().init());

  print('All services started...');
}
