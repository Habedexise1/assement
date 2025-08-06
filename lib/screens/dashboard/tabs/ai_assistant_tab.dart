import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/task_provider.dart';
import '../../../utils/constants.dart';
import 'dart:async'; // Added for Timer

class AIAssistantTab extends StatefulWidget {
  const AIAssistantTab({super.key});

  @override
  State<AIAssistantTab> createState() => _AIAssistantTabState();
}

class _AIAssistantTabState extends State<AIAssistantTab>
    with TickerProviderStateMixin {
  final _promptController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;
  late AnimationController _thinkingAnimationController;
  late AnimationController _pulseAnimationController;
  String _currentThinkingMessage = '';
  int _thinkingMessageIndex = 0;

  final List<String> _thinkingMessages = [
    "🤖 Analyzing your request...",
    "🧠 Processing task requirements...",
    "⚡ Generating optimal task structure...",
    "📊 Considering priorities and deadlines...",
    "🎯 Creating actionable items...",
    "🚀 Optimizing for productivity...",
    "✨ Finalizing your task plan...",
  ];

  @override
  void initState() {
    super.initState();
    _thinkingAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _thinkingAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _startThinkingAnimation() {
    _thinkingMessageIndex = 0;
    _currentThinkingMessage = _thinkingMessages[0];
    _thinkingAnimationController.repeat();
    _pulseAnimationController.repeat();

    // Cycle through thinking messages
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isGenerating) {
        timer.cancel();
        return;
      }

      setState(() {
        _thinkingMessageIndex =
            (_thinkingMessageIndex + 1) % _thinkingMessages.length;
        _currentThinkingMessage = _thinkingMessages[_thinkingMessageIndex];
      });
    });
  }

  void _stopThinkingAnimation() {
    _thinkingAnimationController.stop();
    _pulseAnimationController.stop();
  }

  Future<void> _generateTasks() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (taskProvider.selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project first'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    _startThinkingAnimation();

    try {
      final tasks = await taskProvider.generateTasksWithAI(
        _promptController.text,
      );

      if (mounted) {
        _stopThinkingAnimation();

        // Show success animation
        _pulseAnimationController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Generated ${tasks.length} tasks successfully!'),
              ],
            ),
            backgroundColor: AppConstants.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
        _promptController.clear();
      }
    } catch (e) {
      if (mounted) {
        _stopThinkingAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to generate tasks: ${e.toString()}'),
              ],
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showPersonalizedRecommendations(
    BuildContext context,
    TaskProvider taskProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: AppConstants.secondaryColor),
            SizedBox(width: AppConstants.paddingS),
            Text('AI Learning Report'),
          ],
        ),
        content: FutureBuilder<String>(
          future: taskProvider.getPersonalizedRecommendations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text(
                'Failed to load recommendations: ${snapshot.error}',
                style: const TextStyle(color: AppConstants.errorColor),
              );
            }
            return SingleChildScrollView(
              child: Text(
                snapshot.data ?? 'No personalized recommendations available',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('AI Assistant'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Assistant Header
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isGenerating
                                ? 1.0 + (_pulseAnimationController.value * 0.1)
                                : 1.0,
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppConstants.paddingM,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusM,
                                ),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Task Assistant',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppConstants.paddingXS),
                            Text(
                              'Describe what you want to accomplish and let AI create tasks for you',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingXL),

                // AI Thinking Animation
                if (_isGenerating) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: AppConstants.cardShadow,
                    ),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _thinkingAnimationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle:
                                  _thinkingAnimationController.value *
                                  2 *
                                  3.14159,
                              child: const Icon(
                                Icons.sync,
                                size: 32,
                                color: AppConstants.primaryColor,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Text(
                          _currentThinkingMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        const LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                ],

                // Selected Project
                if (taskProvider.selectedProject != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      boxShadow: AppConstants.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppConstants.parseColor(
                              taskProvider.selectedProject!.color,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusS,
                            ),
                          ),
                          child: const Icon(
                            Icons.folder,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selected Project:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                taskProvider.selectedProject!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: AppConstants.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: AppConstants.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppConstants.warningColor,
                          size: 20,
                        ),
                        SizedBox(width: AppConstants.paddingS),
                        Expanded(
                          child: Text(
                            'Please select a project first to generate tasks',
                            style: TextStyle(
                              color: AppConstants.warningColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                ],

                // Prompt Input
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Describe Your Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      const Text(
                        'Tell the AI what you want to accomplish. Be specific for better results.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      TextFormField(
                        controller: _promptController,
                        style: const TextStyle(color: Colors.black),
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'e.g., Plan my week with 3 work tasks and 2 wellness tasks',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingL),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isGenerating ||
                                  taskProvider.selectedProject == null
                              ? null
                              : _generateTasks,
                          child: _isGenerating
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: AppConstants.paddingS),
                                    Text('AI is Thinking...'),
                                  ],
                                )
                              : const Text('Generate Tasks with AI'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingXL),

                // Sample Prompts
                const Text(
                  'Sample Prompts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                ...AppConstants.samplePrompts
                    .map(
                      (prompt) => Container(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.paddingS,
                        ),
                        child: InkWell(
                          onTap: () {
                            _promptController.text = prompt;
                          },
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppConstants.paddingM,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                              boxShadow: AppConstants.cardShadow,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: AppConstants.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: AppConstants.paddingM),
                                Expanded(
                                  child: Text(
                                    prompt,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),

                const SizedBox(height: AppConstants.paddingXL),

                // Task Insights
                if (taskProvider.tasks.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: AppConstants.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: AppConstants.primaryColor,
                              size: 24,
                            ),
                            SizedBox(width: AppConstants.paddingS),
                            Text(
                              'AI Task Insights',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        FutureBuilder<String>(
                          future: taskProvider.getTaskInsights(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text(
                                'Failed to load insights: ${snapshot.error}',
                                style: const TextStyle(
                                  color: AppConstants.errorColor,
                                ),
                              );
                            }
                            return Text(
                              snapshot.data ?? 'No insights available',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showPersonalizedRecommendations(
                              context,
                              taskProvider,
                            ),
                            icon: const Icon(Icons.psychology),
                            label: const Text(
                              'Get Personalized AI Recommendations',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
