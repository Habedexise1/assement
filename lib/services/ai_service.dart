import '../models/task.dart';
import 'dart:math';

class AIService {
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const int _apiDelay = 2000; // Longer delay for AI operations

  // Simulated AI personality and response patterns
  final List<String> _aiThinkingPhrases = [
    "Analyzing your request...",
    "Processing task requirements...",
    "Generating optimal task structure...",
    "Considering priorities and deadlines...",
    "Creating actionable items...",
    "Optimizing for productivity...",
  ];

  final List<String> _aiSuccessPhrases = [
    "I've created a comprehensive task plan for you!",
    "Here are your optimized tasks based on your request:",
    "I've analyzed your needs and generated the following tasks:",
    "Based on your description, here's what I recommend:",
    "I've structured your goals into actionable tasks:",
  ];

  Future<List<Task>> generateTasksFromPrompt(
    String prompt,
    String projectId,
    String userId,
  ) async {
    try {
      // Simulate AI "thinking" with variable delay
      final thinkingDelay = _apiDelay + Random().nextInt(1000);
      await Future.delayed(Duration(milliseconds: thinkingDelay));

      // Mock AI response based on prompt analysis
      final tasks = _generateMockTasks(prompt, projectId, userId);

      return tasks;
    } catch (e) {
      throw Exception('Failed to generate tasks: ${e.toString()}');
    }
  }

  Future<DateTime?> suggestNewTimeForTask(Task task) async {
    try {
      // Simulate AI analysis delay
      await Future.delayed(Duration(milliseconds: _apiDelay));

      if (!task.isOverdue) {
        throw Exception('Task is not overdue');
      }

      // Enhanced AI suggestion logic
      final now = DateTime.now();
      final random = Random();

      // AI considers different factors for rescheduling
      final suggestionType = random.nextInt(3);
      DateTime suggestedTime;

      switch (suggestionType) {
        case 0:
          // Suggest tomorrow morning (most common)
          suggestedTime = DateTime(
            now.year,
            now.month,
            now.day + 1,
            9 + random.nextInt(3), // 9-11 AM
            0,
          );
          break;
        case 1:
          // Suggest same day, later time
          suggestedTime = DateTime(
            now.year,
            now.month,
            now.day,
            14 + random.nextInt(4), // 2-5 PM
            0,
          );
          break;
        case 2:
          // Suggest next week
          suggestedTime = DateTime(
            now.year,
            now.month,
            now.day + 7,
            10 + random.nextInt(2), // 10-11 AM
            0,
          );
          break;
        default:
          suggestedTime = DateTime(now.year, now.month, now.day + 1, 10, 0);
      }

      return suggestedTime;
    } catch (e) {
      throw Exception('Failed to suggest new time: ${e.toString()}');
    }
  }

  Future<String> getTaskInsights(List<Task> tasks) async {
    try {
      // Simulate AI analysis delay
      await Future.delayed(Duration(milliseconds: _apiDelay));

      final completedTasks = tasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final totalTasks = tasks.length;
      final completionRate = totalTasks > 0
          ? (completedTasks / totalTasks * 100).round()
          : 0;

      final overdueTasks = tasks.where((task) => task.isOverdue).length;
      final highPriorityTasks = tasks
          .where((task) => task.priority == TaskPriority.high)
          .length;
      final inProgressTasks = tasks
          .where((task) => task.status == TaskStatus.inProgress)
          .length;

      // Enhanced AI insights with more sophisticated analysis
      return _generateEnhancedInsights(
        tasks,
        completedTasks,
        totalTasks,
        completionRate,
        overdueTasks,
        highPriorityTasks,
        inProgressTasks,
      );
    } catch (e) {
      throw Exception('Failed to get insights: ${e.toString()}');
    }
  }

  String _generateEnhancedInsights(
    List<Task> tasks,
    int completedTasks,
    int totalTasks,
    int completionRate,
    int overdueTasks,
    int highPriorityTasks,
    int inProgressTasks,
  ) {
    final random = Random();
    final aiPhrase =
        _aiSuccessPhrases[random.nextInt(_aiSuccessPhrases.length)];

    final insights = StringBuffer();
    insights.writeln('🤖 AI Analysis Report');
    insights.writeln('==================');
    insights.writeln();
    insights.writeln('$aiPhrase');
    insights.writeln();

    // Performance Metrics
    insights.writeln('📊 Performance Metrics:');
    insights.writeln('• Completion Rate: $completionRate%');
    insights.writeln('• Completed Tasks: $completedTasks/$totalTasks');
    insights.writeln('• In Progress: $inProgressTasks');
    insights.writeln('• Overdue Tasks: $overdueTasks');
    insights.writeln('• High Priority: $highPriorityTasks');
    insights.writeln();

    // AI-generated insights based on data patterns
    if (completionRate >= 80) {
      insights.writeln(
        '🎉 Excellent work! Your completion rate shows strong productivity.',
      );
    } else if (completionRate >= 60) {
      insights.writeln(
        '👍 Good progress! You\'re maintaining steady momentum.',
      );
    } else if (completionRate >= 40) {
      insights.writeln(
        '📈 Room for improvement. Consider breaking down larger tasks.',
      );
    } else {
      insights.writeln(
        '⚠️  Low completion rate detected. Let\'s focus on prioritization.',
      );
    }
    insights.writeln();

    // Task distribution analysis
    if (highPriorityTasks > totalTasks * 0.5) {
      insights.writeln(
        '⚠️  High priority task overload detected. Consider delegation.',
      );
    } else if (highPriorityTasks == 0) {
      insights.writeln('💡 No high priority tasks. Great for reducing stress!');
    }
    insights.writeln();

    // Recommendations
    insights.writeln('💡 AI Recommendations:');
    insights.writeln(
      _generateSmartRecommendations(
        tasks,
        completionRate,
        overdueTasks,
        highPriorityTasks,
      ),
    );
    insights.writeln();

    // Productivity tips
    insights.writeln('🚀 Productivity Tips:');
    insights.writeln(_generateProductivityTips(completionRate, overdueTasks));

    return insights.toString();
  }

  String _generateSmartRecommendations(
    List<Task> tasks,
    int completionRate,
    int overdueTasks,
    int highPriorityTasks,
  ) {
    final recommendations = <String>[];

    if (overdueTasks > 0) {
      recommendations.add(
        '• Focus on completing overdue tasks first to maintain momentum',
      );
    }

    if (highPriorityTasks > 3) {
      recommendations.add(
        '• Consider breaking down high-priority tasks into smaller subtasks',
      );
    }

    if (completionRate < 50) {
      recommendations.add('• Try the Pomodoro technique for better focus');
      recommendations.add('• Set realistic deadlines and avoid overcommitment');
    }

    if (tasks.where((t) => t.priority == TaskPriority.low).length > 5) {
      recommendations.add('• Batch low-priority tasks together for efficiency');
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        '• Keep up the excellent work! Your task management is on point',
      );
      recommendations.add(
        '• Consider setting stretch goals to challenge yourself',
      );
    }

    return recommendations.join('\n');
  }

  String _generateProductivityTips(int completionRate, int overdueTasks) {
    final tips = <String>[];
    final random = Random();

    if (completionRate < 70) {
      tips.addAll([
        '• Use time blocking to allocate specific time for tasks',
        '• Eliminate distractions during focused work sessions',
        '• Review and adjust your task priorities daily',
      ]);
    }

    if (overdueTasks > 0) {
      tips.addAll([
        '• Set buffer time between tasks for unexpected delays',
        '• Use the 2-minute rule: if it takes less than 2 minutes, do it now',
      ]);
    }

    // Add some general tips
    tips.addAll([
      '• Take regular breaks to maintain mental clarity',
      '• Celebrate small wins to stay motivated',
    ]);

    // Randomize the order and limit to 3-4 tips
    tips.shuffle(random);
    return tips.take(3 + random.nextInt(2)).join('\n');
  }

  List<Task> _generateMockTasks(
    String prompt,
    String projectId,
    String userId,
  ) {
    final now = DateTime.now();
    final tasks = <Task>[];
    final random = Random();

    // Enhanced prompt analysis with more sophisticated patterns
    final promptLower = prompt.toLowerCase();

    if (promptLower.contains('work') && promptLower.contains('wellness')) {
      // Work and wellness balance tasks
      tasks.addAll([
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Review weekly project progress and update stakeholders',
          description:
              'Analyze current project status, identify blockers, and prepare status report for team meeting',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 2, 17, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['work', 'review', 'communication'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Prepare client presentation slides',
          description:
              'Create engaging presentation with key metrics, progress updates, and next steps',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 1, 14, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['work', 'presentation', 'client'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Code review for feature branch',
          description:
              'Review pull request, test functionality, and provide constructive feedback to team member',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 1, 16, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['work', 'development', 'collaboration'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_4',
          title: 'Mindfulness meditation session',
          description:
              '30-minute guided meditation focusing on stress relief and mental clarity',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day, 20, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['wellness', 'meditation', 'stress-relief'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_5',
          title: 'Evening walk and fresh air',
          description:
              '30-minute walk in the park to clear mind and get light exercise',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.low,
          dueDate: DateTime(now.year, now.month, now.day, 19, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['wellness', 'exercise', 'outdoor'],
        ),
      ]);
    } else if (promptLower.contains('study') ||
        promptLower.contains('learning')) {
      // Enhanced study tasks
      tasks.addAll([
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Read and take notes on Flutter state management',
          description:
              'Focus on Chapter 5 of Flutter Cookbook, practice examples, and create summary notes',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 1, 21, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['study', 'flutter', 'state-management'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Complete online course module and quiz',
          description:
              'Finish current module, take assessment quiz, and review incorrect answers',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 2, 18, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['study', 'course', 'assessment'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Practice coding exercises on LeetCode',
          description:
              'Solve 3 medium-difficulty problems focusing on algorithms and data structures',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 1, 20, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['study', 'coding', 'algorithms'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_4',
          title: 'Create study summary and flashcards',
          description:
              'Review today\'s learning and create digital flashcards for retention',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.low,
          dueDate: DateTime(now.year, now.month, now.day + 1, 22, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['study', 'review', 'retention'],
        ),
      ]);
    } else if (promptLower.contains('project') ||
        promptLower.contains('development')) {
      // Project development tasks
      tasks.addAll([
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Project planning and requirements gathering',
          description:
              'Define project scope, create user stories, and establish technical requirements',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 1, 17, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['project', 'planning', 'requirements'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Set up development environment',
          description:
              'Install necessary tools, configure IDE, and set up version control',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day, 16, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['project', 'setup', 'development'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Create project documentation',
          description:
              'Write README, API documentation, and setup instructions',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 2, 15, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['project', 'documentation', 'setup'],
        ),
      ]);
    } else {
      // Generic intelligent task generation
      tasks.addAll([
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Analyze and prioritize current workload',
          description:
              'Review all pending tasks, assess priorities, and create action plan',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 1, 17, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['planning', 'prioritization'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Follow up on pending items and communications',
          description:
              'Check email, respond to messages, and update stakeholders on progress',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 2, 16, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['communication', 'follow-up'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Organize workspace and digital files',
          description:
              'Clean up desktop, organize project folders, and backup important files',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.low,
          dueDate: DateTime(now.year, now.month, now.day + 1, 18, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['organization', 'maintenance'],
        ),
      ]);
    }

    return tasks;
  }

  // Real AI API integration (commented out for now)
  /*
  Future<List<Task>> _callOpenAI(String prompt, String projectId, String userId) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null) {
      throw Exception('OpenAI API key not found');
    }

    final response = await http.post(
      Uri.parse('$_openaiBaseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful task management assistant. Generate 3-5 specific, actionable tasks based on the user\'s prompt. Return only a JSON array of task objects with title, description, priority (low/medium/high), and due_date (ISO string).',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 500,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'];
      final tasksJson = json.decode(content);
      
      return (tasksJson as List).map((taskJson) {
        return Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_${tasksJson.indexOf(taskJson)}',
          title: taskJson['title'],
          description: taskJson['description'],
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.values.firstWhere(
            (e) => e.toString().split('.').last == taskJson['priority'],
            orElse: () => TaskPriority.medium,
          ),
          dueDate: DateTime.parse(taskJson['due_date']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    } else {
      throw Exception('OpenAI API request failed: ${response.statusCode}');
    }
  }
  */

  // Simulated AI Learning and Adaptation
  Future<String> getPersonalizedRecommendations(
    List<Task> tasks,
    String userId,
  ) async {
    try {
      // Simulate AI analysis delay
      await Future.delayed(Duration(milliseconds: _apiDelay));

      final completedTasks = tasks
          .where((task) => task.status == TaskStatus.completed)
          .toList();
      final overdueTasks = tasks.where((task) => task.isOverdue).toList();

      if (completedTasks.isEmpty) {
        return '🤖 AI Learning: I\'m still learning about your work patterns. Complete a few tasks to get personalized recommendations!';
      }

      // Analyze user patterns
      final avgCompletionTime = _calculateAverageCompletionTime(completedTasks);
      final preferredTimeSlots = _analyzePreferredTimeSlots(completedTasks);
      final commonTags = _analyzeCommonTags(completedTasks);
      final productivityPatterns = _analyzeProductivityPatterns(completedTasks);

      final recommendations = StringBuffer();
      recommendations.writeln('🤖 AI Learning Report');
      recommendations.writeln('==================');
      recommendations.writeln();
      recommendations.writeln(
        'Based on your task completion patterns, here\'s what I\'ve learned:',
      );
      recommendations.writeln();

      // Time-based insights
      if (avgCompletionTime != null) {
        recommendations.writeln('⏰ Time Patterns:');
        recommendations.writeln(
          '• Average task completion time: ${avgCompletionTime.inHours}h ${avgCompletionTime.inMinutes % 60}m',
        );
        if (preferredTimeSlots.isNotEmpty) {
          recommendations.writeln(
            '• Your most productive hours: ${preferredTimeSlots.join(', ')}',
          );
        }
        recommendations.writeln();
      }

      // Tag-based insights
      if (commonTags.isNotEmpty) {
        recommendations.writeln('🏷️  Task Categories:');
        recommendations.writeln(
          '• You excel at: ${commonTags.take(3).join(', ')}',
        );
        recommendations.writeln();
      }

      // Productivity insights
      if (productivityPatterns.isNotEmpty) {
        recommendations.writeln('📈 Productivity Insights:');
        recommendations.writeln(productivityPatterns);
        recommendations.writeln();
      }

      // Personalized recommendations
      recommendations.writeln('💡 Personalized Recommendations:');
      recommendations.writeln(
        _generatePersonalizedTips(completedTasks, overdueTasks),
      );

      return recommendations.toString();
    } catch (e) {
      return '🤖 AI Learning: Unable to analyze patterns at the moment.';
    }
  }

  Duration? _calculateAverageCompletionTime(List<Task> completedTasks) {
    if (completedTasks.length < 2) return null;

    final completionTimes = <Duration>[];
    for (final task in completedTasks) {
      if (task.completedAt != null && task.createdAt != null) {
        completionTimes.add(task.completedAt!.difference(task.createdAt!));
      }
    }

    if (completionTimes.isEmpty) return null;

    final totalMinutes = completionTimes.fold<int>(
      0,
      (sum, duration) => sum + duration.inMinutes,
    );
    return Duration(minutes: totalMinutes ~/ completionTimes.length);
  }

  List<String> _analyzePreferredTimeSlots(List<Task> completedTasks) {
    final timeSlots = <String>[];
    final hourCounts = <int, int>{};

    for (final task in completedTasks) {
      if (task.completedAt != null) {
        final hour = task.completedAt!.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    if (hourCounts.isEmpty) return timeSlots;

    // Find the top 3 most productive hours
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedHours.take(3)) {
      final hour = entry.key;
      if (hour < 12) {
        timeSlots.add('${hour}AM');
      } else if (hour == 12) {
        timeSlots.add('12PM');
      } else {
        timeSlots.add('${hour - 12}PM');
      }
    }

    return timeSlots;
  }

  List<String> _analyzeCommonTags(List<Task> completedTasks) {
    final tagCounts = <String, int>{};

    for (final task in completedTasks) {
      for (final tag in task.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    if (tagCounts.isEmpty) return [];

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.map((e) => e.key).toList();
  }

  String _analyzeProductivityPatterns(List<Task> completedTasks) {
    final patterns = <String>[];

    // Analyze completion patterns
    final highPriorityCompleted = completedTasks
        .where((task) => task.priority == TaskPriority.high)
        .length;
    final totalHighPriority = completedTasks.length;

    if (highPriorityCompleted > totalHighPriority * 0.7) {
      patterns.add('• You\'re excellent at prioritizing high-importance tasks');
    }

    // Analyze timing patterns
    final onTimeCompletions = completedTasks
        .where((task) => task.completedAt != null && task.dueDate != null)
        .where((task) => task.completedAt!.isBefore(task.dueDate!))
        .length;

    if (onTimeCompletions > completedTasks.length * 0.8) {
      patterns.add('• You consistently meet deadlines');
    }

    if (patterns.isEmpty) {
      patterns.add('• You\'re building consistent task completion habits');
    }

    return patterns.join('\n');
  }

  String _generatePersonalizedTips(
    List<Task> completedTasks,
    List<Task> overdueTasks,
  ) {
    final tips = <String>[];

    // Based on completion patterns
    if (completedTasks.length > 10) {
      tips.add(
        '• You\'re a task completion pro! Consider taking on more challenging projects',
      );
    } else if (completedTasks.length < 5) {
      tips.add('• Start with smaller, achievable tasks to build momentum');
    }

    // Based on overdue tasks
    if (overdueTasks.isNotEmpty) {
      tips.add(
        '• Consider setting earlier deadlines to account for unexpected delays',
      );
    }

    // Based on task types
    final workTasks = completedTasks
        .where((t) => t.tags.contains('work'))
        .length;
    final wellnessTasks = completedTasks
        .where((t) => t.tags.contains('wellness'))
        .length;

    if (workTasks > wellnessTasks * 2) {
      tips.add(
        '• Great work focus! Remember to balance with wellness activities',
      );
    } else if (wellnessTasks > workTasks) {
      tips.add('• Excellent work-life balance! Keep it up');
    }

    if (tips.isEmpty) {
      tips.add(
        '• Keep experimenting with different task types to find your sweet spot',
      );
    }

    return tips.join('\n');
  }
}
