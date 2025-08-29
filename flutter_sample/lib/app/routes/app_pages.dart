import 'package:get/get.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/ai_assistant/ai_assistant_page.dart';
import '../bindings/home_binding.dart';
import '../bindings/ai_assistant_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.HOME;

  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.AI_ASSISTANT,
      page: () => const AiAssistantPage(),
      binding: AiAssistantBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
