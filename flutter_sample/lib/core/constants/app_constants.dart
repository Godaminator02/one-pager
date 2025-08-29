class AppConstants {
  static const String appName = 'Mind Map AI';
  static const String version = '1.0.0';
  static const int aiTypingDelay = 100;
  static const int autoSaveInterval = 30; // seconds
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;
  static const int animationDuration = 300;
}

class ApiConstants {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String chatCompletionsEndpoint = '/chat/completions';
  static const int timeoutDuration = 30000; // milliseconds
}
