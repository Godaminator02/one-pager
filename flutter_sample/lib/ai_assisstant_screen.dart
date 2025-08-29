// AI Assistant Screen - Ultra Premium Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AIAssistantScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedMaps;

  const AIAssistantScreen({Key? key, required this.savedMaps})
    : super(key: key);

  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isLoading = false;

  late AnimationController _gradientController;
  late AnimationController _messageController1;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Premium color palette
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryBlue = Color(0xFF74B9FF);
  static const Color accentPink = Color(0xFFE17055);
  static const Color accentGreen = Color(0xFF00B894);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF16213E);
  static const Color glassBg = Color(0x80FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color textTertiary = Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _messageController1 = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _messageController1, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _messageController1,
            curve: Curves.easeOutCubic,
          ),
        );

    // Welcome message
    _chatMessages.add({
      'sender': 'assistant',
      'message':
          '👋 Welcome to your AI Mind Map Assistant! I\'m here to help you analyze, improve, and get insights from your mind maps. What would you like to explore today?',
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    _messageController1.forward();
  }

  // Ask AI method (placeholder for future AI integration)
  Future<String> _askAI(String question) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    // Placeholder responses based on question type
    if (question.toLowerCase().contains('analyze') ||
        question.toLowerCase().contains('analysis')) {
      return "Based on your mind map, I can see several key themes and connections. The central concept appears to be well-developed with multiple branching ideas. I'd suggest strengthening the connections between related concepts and consider adding more detail to some of the secondary branches.";
    } else if (question.toLowerCase().contains('improve') ||
        question.toLowerCase().contains('better')) {
      return "Here are some suggestions to improve your mind map:\n\n1. Add more visual elements like colors and icons\n2. Group related concepts closer together\n3. Use different line styles to show different types of relationships\n4. Consider adding a legend to explain your notation system";
    } else if (question.toLowerCase().contains('summary') ||
        question.toLowerCase().contains('summarize')) {
      return "Your mind map covers ${widget.savedMaps.length} different topics. The most recent activity shows active development in brainstorming and concept organization. Key patterns include hierarchical thinking and creative associations.";
    } else {
      return "I understand your question about '${question.length > 50 ? question.substring(0, 50) + '...' : question}'. While I'm currently in demo mode, I can help you analyze mind map structures, suggest improvements, and provide insights about your thinking patterns.";
    }
  }

  // Extract text from map data (placeholder implementation)
  String _extractTextFromMap(Map<String, dynamic> mapData) {
    // This would normally parse the Excalidraw data structure
    // For now, return a placeholder
    return "Mind map created on ${DateTime.fromMillisecondsSinceEpoch(mapData['created_at']).toString().split(' ')[0]} with multiple elements and connections.";
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _chatMessages.add({
        'sender': 'user',
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      _isLoading = true;
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      String response;
      if (message.toLowerCase().contains('analyze my maps')) {
        // Analyze all saved maps
        final analysisData = widget.savedMaps
            .map((map) => _extractTextFromMap(map))
            .join('\n');
        response = await _askAI('Analyze these mind maps: $analysisData');
      } else {
        response = await _askAI(message);
      }

      setState(() {
        _chatMessages.add({
          'sender': 'assistant',
          'message': response,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        });
        _isLoading = false;
      });

      // Auto scroll to bottom after response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _chatMessages.add({
          'sender': 'assistant',
          'message':
              '⚠️ Sorry, I encountered an error while processing your request. Please try again.',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkBg, cardBg, const Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Premium App Bar
              _buildPremiumAppBar(context),

              // Chat Messages Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              glassBg.withOpacity(0.1),
                              glassBg.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(20),
                            itemCount:
                                _chatMessages.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _chatMessages.length && _isLoading) {
                                return _buildLoadingMessage();
                              }
                              return _buildMessage(_chatMessages[index], index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Premium Input Area
              _buildPremiumInputArea(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button with Glass Effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: glassBg.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textPrimary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title with Gradient
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryPurple, primaryBlue],
                  ).createShader(bounds),
                  child: const Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mind Map Intelligence',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [accentGreen, accentGreen.withOpacity(0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentGreen.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, String> message, int index) {
    final isUser = message['sender'] == 'user';
    final isRecent = index >= _chatMessages.length - 3;

    return FadeTransition(
      opacity: isRecent ? _fadeAnimation : const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: isRecent
            ? _slideAnimation
            : const AlwaysStoppedAnimation(Offset.zero),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[_buildAvatar(false), const SizedBox(width: 12)],

              Flexible(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryPurple, primaryBlue],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cardBg.withOpacity(0.8),
                              cardBg.withOpacity(0.6),
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? primaryPurple.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['message']!,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      if (message['timestamp'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(message['timestamp']!),
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (isUser) ...[const SizedBox(width: 12), _buildAvatar(true)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildAvatar(false),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardBg.withOpacity(0.8), cardBg.withOpacity(0.6)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? LinearGradient(colors: [accentPink, accentPink.withOpacity(0.7)])
            : LinearGradient(colors: [primaryPurple, primaryBlue]),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: (isUser ? accentPink : primaryPurple).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.psychology_rounded,
        color: textPrimary,
        size: 20,
      ),
    );
  }

  Widget _buildPremiumInputArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glassBg.withOpacity(0.1), glassBg.withOpacity(0.05)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quick action buttons
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                _buildQuickActionButton(
                  icon: Icons.lightbulb_outline_rounded,
                  onTap: () =>
                      _addQuickMessage('Give me insights about my mind maps'),
                ),
                const SizedBox(width: 8),
                _buildQuickActionButton(
                  icon: Icons.analytics_outlined,
                  onTap: () => _addQuickMessage('Analyze my thinking patterns'),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: cardBg.withOpacity(0.3),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask me anything about your mind maps...',
                  hintStyle: TextStyle(color: textTertiary, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isLoading
                        ? LinearGradient(
                            colors: [
                              textTertiary.withOpacity(0.5),
                              textTertiary.withOpacity(0.3),
                            ],
                          )
                        : LinearGradient(colors: [primaryPurple, primaryBlue]),
                    boxShadow: _isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: Icon(Icons.send_rounded, color: textPrimary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cardBg.withOpacity(0.5),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Icon(icon, color: textSecondary, size: 16),
        ),
      ),
    );
  }

  void _addQuickMessage(String message) {
    _messageController.text = message;
    HapticFeedback.selectionClick();
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _gradientController.dispose();
    _messageController1.dispose();
    super.dispose();
  }
}
