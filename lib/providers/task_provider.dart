import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final AIService _aiService = AIService();

  List<Project> _projects = [];
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  Project? _selectedProject;

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Project? get selectedProject => _selectedProject;

  List<Task> get tasksForSelectedProject {
    if (_selectedProject == null) return _tasks;
    return _tasks
        .where((task) => task.projectId == _selectedProject!.id)
        .toList();
  }

  List<Task> get overdueTasks {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<Task> get todayTasks {
    return _tasks.where((task) => task.isDueToday).toList();
  }

  List<Task> get highPriorityTasks {
    return _tasks.where((task) => task.priority == TaskPriority.high).toList();
  }

  TaskProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _setLoading(true);
    try {
      await _loadProjects();
      await _loadTasks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadProjects() async {
    try {
      final box = await Hive.openBox<Project>('projects');
      _projects = box.values.toList();
      if (_projects.isNotEmpty && _selectedProject == null) {
        _selectedProject = _projects.first;
      }
    } catch (e) {
      _error = 'Failed to load projects: ${e.toString()}';
    }
  }

  Future<void> _loadTasks() async {
    try {
      final box = await Hive.openBox<Task>('tasks');
      _tasks = box.values.toList();
    } catch (e) {
      _error = 'Failed to load tasks: ${e.toString()}';
    }
  }

  Future<void> createProject(
    String name,
    String description,
    String color,
  ) async {
    _setLoading(true);
    try {
      final project = Project(
        id: 'project_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        color: color,
        userId: 'current_user_id', // This should come from auth
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final box = await Hive.openBox<Project>('projects');
      await box.add(project);
      _projects.add(project);

      if (_selectedProject == null) {
        _selectedProject = project;
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create project: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProject(Project project) async {
    _setLoading(true);
    try {
      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      final box = await Hive.openBox<Project>('projects');

      // Find the existing project in the box and update it
      final existingProject = _projects.firstWhere((p) => p.id == project.id);
      await box.put(existingProject.key, updatedProject);

      // Reload projects from Hive to ensure consistency
      await _loadProjects();

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update project: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProject(String projectId) async {
    _setLoading(true);
    try {
      final box = await Hive.openBox<Project>('projects');
      final project = _projects.firstWhere((p) => p.id == projectId);
      await box.delete(project.key);
      _projects.removeWhere((p) => p.id == projectId);

      // Delete associated tasks
      final taskBox = await Hive.openBox<Task>('tasks');
      final tasksToDelete = _tasks
          .where((t) => t.projectId == projectId)
          .toList();
      for (final task in tasksToDelete) {
        await taskBox.delete(task.key);
      }
      _tasks.removeWhere((t) => t.projectId == projectId);

      if (_selectedProject?.id == projectId) {
        _selectedProject = _projects.isNotEmpty ? _projects.first : null;
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete project: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTask(
    String title,
    String description,
    TaskPriority priority,
    DateTime? dueDate,
  ) async {
    if (_selectedProject == null) {
      _error = 'Please select a project first';
      notifyListeners();
      return;
    }

    await _createTaskInternal(
      title: title,
      description: description,
      projectId: _selectedProject!.id,
      userId: 'current_user_id', // This should come from auth
      priority: priority,
      dueDate: dueDate,
    );
  }

  Future<void> createTaskForUser(
    String title,
    String description,
    String projectId,
    String userId,
    TaskPriority priority,
    DateTime? dueDate,
  ) async {
    await _createTaskInternal(
      title: title,
      description: description,
      projectId: projectId,
      userId: userId,
      priority: priority,
      dueDate: dueDate,
    );
  }

  Future<void> _createTaskInternal({
    required String title,
    required String description,
    required String projectId,
    required String userId,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    _setLoading(true);
    try {
      final task = Task(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        projectId: projectId,
        userId: userId,
        priority: priority,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final box = await Hive.openBox<Task>('tasks');
      await box.add(task);
      _tasks.add(task);

      // Schedule notification if task has due date
      if (task.dueDate != null) {
        await NotificationService().scheduleTaskReminder(task);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create task: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(Task task) async {
    _setLoading(true);
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      final box = await Hive.openBox<Task>('tasks');
      await box.put(task.key, updatedTask);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }

      // Update notifications if due date changed
      if (task.dueDate != null) {
        await NotificationService().cancelTaskNotifications(task.id);
        await NotificationService().scheduleTaskReminder(updatedTask);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update task: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTask(String taskId) async {
    _setLoading(true);
    try {
      final box = await Hive.openBox<Task>('tasks');
      final task = _tasks.firstWhere((t) => t.id == taskId);
      await box.delete(task.key);
      _tasks.removeWhere((t) => t.id == taskId);

      // Cancel notifications for deleted task
      await NotificationService().cancelTaskNotifications(taskId);

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskStatus(String taskId) async {
    _setLoading(true);
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);

      // Cycle through statuses: pending -> inProgress -> readyForQA -> completed -> pending
      TaskStatus newStatus;
      switch (task.status) {
        case TaskStatus.pending:
          newStatus = TaskStatus.inProgress;
          break;
        case TaskStatus.inProgress:
          newStatus = TaskStatus.readyForQA;
          break;
        case TaskStatus.readyForQA:
          newStatus = TaskStatus.completed;
          break;
        case TaskStatus.completed:
        case TaskStatus.overdue:
          newStatus = TaskStatus.pending;
          break;
      }

      final updatedTask = task.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      await updateTask(updatedTask);
    } catch (e) {
      _error = 'Failed to toggle task status: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  Future<List<Task>> generateTasksWithAI(String prompt) async {
    if (_selectedProject == null) {
      throw Exception('Please select a project first');
    }

    _setLoading(true);
    try {
      final tasks = await _aiService.generateTasksFromPrompt(
        prompt,
        _selectedProject!.id,
        'current_user_id', // This should come from auth
      );

      // Save generated tasks
      final box = await Hive.openBox<Task>('tasks');
      for (final task in tasks) {
        await box.add(task);
        _tasks.add(task);
      }

      _error = null;
      notifyListeners();
      return tasks;
    } catch (e) {
      _error = 'Failed to generate tasks: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<DateTime?> suggestNewTimeForTask(Task task) async {
    try {
      return await _aiService.suggestNewTimeForTask(task);
    } catch (e) {
      _error = 'Failed to suggest new time: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<String> getTaskInsights() async {
    try {
      return await _aiService.getTaskInsights(_tasks);
    } catch (e) {
      _error = 'Failed to get insights: ${e.toString()}';
      notifyListeners();
      return 'Failed to load insights';
    }
  }

  Future<String> getPersonalizedRecommendations() async {
    try {
      return await _aiService.getPersonalizedRecommendations(
        _tasks,
        'current_user_id',
      );
    } catch (e) {
      _error = 'Failed to get personalized recommendations: ${e.toString()}';
      notifyListeners();
      return 'Failed to load personalized recommendations';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
