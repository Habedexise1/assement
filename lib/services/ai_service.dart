import '../models/task.dart';

class AIService {
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const int _apiDelay = 2000; // Longer delay for AI operations

  Future<List<Task>> generateTasksFromPrompt(
    String prompt,
    String projectId,
    String userId,
  ) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: _apiDelay));

      // Mock AI response based on prompt
      final tasks = _generateMockTasks(prompt, projectId, userId);

      return tasks;
    } catch (e) {
      throw Exception('Failed to generate tasks: ${e.toString()}');
    }
  }

  Future<DateTime?> suggestNewTimeForTask(Task task) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: _apiDelay));

      if (!task.isOverdue) {
        throw Exception('Task is not overdue');
      }

      // Mock AI suggestion logic
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day + 1,
        10,
        0,
      ); // 10 AM tomorrow

      return tomorrow;
    } catch (e) {
      throw Exception('Failed to suggest new time: ${e.toString()}');
    }
  }

  Future<String> getTaskInsights(List<Task> tasks) async {
    try {
      // Simulate API delay
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

      return '''
Task Insights:
• Completion Rate: $completionRate%
• Completed Tasks: $completedTasks/$totalTasks
• Overdue Tasks: $overdueTasks
• High Priority Tasks: $highPriorityTasks

Recommendations:
${_generateRecommendations(tasks)}
''';
    } catch (e) {
      throw Exception('Failed to get insights: ${e.toString()}');
    }
  }

  List<Task> _generateMockTasks(
    String prompt,
    String projectId,
    String userId,
  ) {
    final now = DateTime.now();
    final tasks = <Task>[];

    if (prompt.toLowerCase().contains('work') &&
        prompt.toLowerCase().contains('wellness')) {
      // Work and wellness tasks
      tasks.addAll([
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Review weekly project progress',
          description: 'Analyze current project status and update stakeholders',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 2, 17, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['work', 'review'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Prepare client presentation',
          description: 'Create slides for upcoming client meeting',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 1, 14, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['work', 'presentation'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Code review for feature branch',
          description: 'Review pull request and provide feedback',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 1, 16, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['work', 'development'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_4',
          title: '30-minute meditation session',
          description: 'Practice mindfulness and stress relief',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day, 20, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['wellness', 'meditation'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_5',
          title: 'Evening walk in the park',
          description: 'Get some fresh air and light exercise',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.low,
          dueDate: DateTime(now.year, now.month, now.day, 19, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['wellness', 'exercise'],
        ),
      ]);
    } else if (prompt.toLowerCase().contains('study') ||
        prompt.toLowerCase().contains('learning')) {
      // Study tasks
      tasks.addAll([
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Read Chapter 5 of Flutter Cookbook',
          description: 'Focus on state management patterns',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 1, 21, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['study', 'flutter'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Complete online course module',
          description: 'Finish the current module and take the quiz',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 2, 18, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['study', 'course'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Practice coding exercises',
          description: 'Work on 3 coding problems on LeetCode',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 1, 20, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['study', 'coding'],
        ),
      ]);
    } else {
      // Generic tasks
      tasks.addAll([
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Complete important task',
          description: 'This is a high priority task that needs attention',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.high,
          dueDate: DateTime(now.year, now.month, now.day + 1, 17, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['important'],
        ),
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Follow up on pending items',
          description: 'Check status of ongoing projects and tasks',
          projectId: projectId,
          userId: userId,
          priority: TaskPriority.medium,
          dueDate: DateTime(now.year, now.month, now.day + 2, 16, 0),
          createdAt: now,
          updatedAt: now,
          tags: ['follow-up'],
        ),
      ]);
    }

    return tasks;
  }

  String _generateRecommendations(List<Task> tasks) {
    final overdueTasks = tasks.where((task) => task.isOverdue).length;
    final highPriorityTasks = tasks
        .where((task) => task.priority == TaskPriority.high)
        .length;

    final recommendations = <String>[];

    if (overdueTasks > 0) {
      recommendations.add('• Focus on completing overdue tasks first');
    }

    if (highPriorityTasks > 3) {
      recommendations.add('• Consider delegating some high-priority tasks');
    }

    if (recommendations.isEmpty) {
      recommendations.add('• Great job! Keep up the good work');
    }

    return recommendations.join('\n');
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
}
