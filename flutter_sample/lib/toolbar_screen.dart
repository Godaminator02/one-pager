import 'package:flutter/material.dart';

class ToolbarScreen extends StatelessWidget {
  final Function(String, {Color? backgroundColor})? onShowSnackBar;
  final VoidCallback? onLoadMaps;
  final VoidCallback? onShowSavedMaps;
  final VoidCallback? onShowAIChat;
  final VoidCallback? onSaveMindMap;
  final VoidCallback? onLoadMindMap;
  final VoidCallback? onExportJson;
  final VoidCallback? onImportJson;
  final VoidCallback? onExportGraphML;

  const ToolbarScreen({
    super.key,
    this.onShowSnackBar,
    this.onLoadMaps,
    this.onShowSavedMaps,
    this.onShowAIChat,
    this.onSaveMindMap,
    this.onLoadMindMap,
    this.onExportJson,
    this.onImportJson,
    this.onExportGraphML,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF4facfe),
              Color(0xFF00f2fe),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Mind Map Toolkit',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_tree,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Professional Tools for Mind Mapping & AI Integration',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // First Row
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildToolButton(
                                  icon: Icons.save_alt,
                                  title: 'Save Map',
                                  subtitle: 'Store your work',
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF8BC34A),
                                    ],
                                  ),
                                  onTap: onSaveMindMap,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildToolButton(
                                  icon: Icons.storage,
                                  title: 'Saved Maps',
                                  subtitle: 'Browse collection',
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF9C27B0),
                                      Color(0xFFBA68C8),
                                    ],
                                  ),
                                  onTap: onShowSavedMaps,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Second Row
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildToolButton(
                                  icon: Icons.psychology,
                                  title: 'AI Assistant',
                                  subtitle: 'Smart insights',
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF9800),
                                      Color(0xFFFFB74D),
                                    ],
                                  ),
                                  onTap: onShowAIChat,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildToolButton(
                                  icon: Icons.bug_report,
                                  title: 'Test Tools',
                                  subtitle: 'Development',
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF44336),
                                      Color(0xFFEF5350),
                                    ],
                                  ),
                                  onTap: () {
                                    onShowSnackBar?.call(
                                      'TEST: Advanced toolbar functionality active!',
                                      backgroundColor: Colors.deepPurple,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Professional Edition',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
