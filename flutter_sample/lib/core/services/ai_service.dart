import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class AiService extends GetxService {
  static AiService get to => Get.find();

  final String _baseUrl = ApiConstants.baseUrl;
  final Duration _timeout = const Duration(
    milliseconds: ApiConstants.timeoutDuration,
  );

  Future<AiService> init() async {
    // Initialize AI service
    return this;
  }

  Future<String> sendMessage(String message, {String? context}) async {
    try {
      // Simulate AI response for now - replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Placeholder responses based on message content
      if (message.toLowerCase().contains('analyze') ||
          message.toLowerCase().contains('analysis')) {
        return _generateAnalysisResponse(context);
      } else if (message.toLowerCase().contains('improve') ||
          message.toLowerCase().contains('better')) {
        return _generateImprovementResponse();
      } else if (message.toLowerCase().contains('summary') ||
          message.toLowerCase().contains('summarize')) {
        return _generateSummaryResponse(context);
      } else if (message.toLowerCase().contains('explain') ||
          message.toLowerCase().contains('what')) {
        return _generateExplanationResponse(message);
      } else {
        return _generateGenericResponse(message);
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  String _generateAnalysisResponse(String? context) {
    return """Based on your mind map analysis, I can identify several key insights:

🎯 **Central Themes**: Your map shows strong conceptual organization with clear hierarchical structures.

📊 **Pattern Analysis**: I notice recurring themes that suggest systematic thinking patterns.

🔗 **Connections**: The relationships between elements indicate well-developed associative thinking.

💡 **Recommendations**: 
- Consider adding more cross-connections between distant concepts
- Group related ideas with visual clustering
- Add priority indicators to highlight key elements""";
  }

  String _generateImprovementResponse() {
    return """Here are some advanced suggestions to enhance your mind map:

🎨 **Visual Enhancements**:
- Use color coding for different categories
- Add icons and symbols for quick recognition
- Implement consistent line styles

📐 **Structural Improvements**:
- Balance branch distribution
- Maintain consistent spacing
- Use hierarchical sizing for importance

⚡ **Interactive Elements**:
- Add clickable links to resources
- Include progress indicators
- Embed multimedia elements where relevant""";
  }

  String _generateSummaryResponse(String? context) {
    return """**Mind Map Summary**:

📋 **Overview**: Your mind map demonstrates comprehensive coverage of the topic with logical flow and organization.

🎯 **Key Areas**: The map covers multiple dimensions with clear categorization and prioritization.

📈 **Complexity Level**: Medium to high complexity with good depth in core areas.

⭐ **Strengths**: Strong central focus, good branching logic, clear relationships.

🔄 **Usage Patterns**: Shows evidence of iterative development and refinement.""";
  }

  String _generateExplanationResponse(String message) {
    return """I'd be happy to explain that concept! 

Based on your question about "${message.length > 50 ? message.substring(0, 50) + '...' : message}", here's what I can help with:

🧠 **Concept Breakdown**: Mind mapping is a visual thinking tool that helps organize information hierarchically.

🔍 **How it Works**: Central concepts branch out into related subtopics, creating a network of interconnected ideas.

💫 **Benefits**: 
- Enhanced memory retention
- Better creative thinking
- Improved problem-solving
- Clear information structure

Feel free to ask more specific questions about any aspect!""";
  }

  String _generateGenericResponse(String message) {
    return """Thanks for your message! I'm here to help you with mind map analysis and improvement.

Here's what I can assist you with:

🎯 **Analysis**: Deep dive into your mind map structure and patterns
📊 **Optimization**: Suggestions for better organization and visual appeal
💡 **Ideas**: Creative ways to expand and enhance your concepts
🔍 **Insights**: Identify relationships and potential areas for development

Feel free to ask me to analyze, summarize, or provide suggestions for your mind maps. What would you like to explore?""";
  }

  // Future method for actual API integration
  Future<String> _callActualAI(String message, String? context) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl${ApiConstants.chatCompletionsEndpoint}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer YOUR_API_KEY', // Replace with actual API key
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are an AI assistant specialized in mind map analysis and improvement suggestions.',
              },
              if (context != null)
                {'role': 'user', 'content': 'Context: $context'},
              {'role': 'user', 'content': message},
            ],
            'max_tokens': 500,
            'temperature': 0.7,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('AI API request failed: ${response.statusCode}');
    }
  }
}
