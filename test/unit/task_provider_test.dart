import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assesment/providers/task_provider.dart';
import 'package:assesment/models/project.dart';
import 'package:assesment/models/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TaskProvider Tests', () {
    late TaskProvider taskProvider;

    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(ProjectAdapter());
      Hive.registerAdapter(TaskAdapter());
    });

    setUp(() async {
      // Clear Hive boxes before each test
      await Hive.deleteBoxFromDisk('projects');
      await Hive.deleteBoxFromDisk('tasks');
      taskProvider = TaskProvider();
    });

    tearDown(() async {
      // Clean up after each test
      await Hive.deleteBoxFromDisk('projects');
      await Hive.deleteBoxFromDisk('tasks');
    });

    group('Project Management', () {
      test('should create project successfully', () async {
        // Arrange
        const name = 'Test Project';
        const description = 'Test Description';
        const color = '0xFF6366F1';

        // Act
        await taskProvider.createProject(name, description, color);

        // Assert
        expect(taskProvider.projects.length, equals(1));
        expect(taskProvider.projects.first.name, equals(name));
        expect(taskProvider.projects.first.description, equals(description));
        expect(taskProvider.projects.first.color, equals(color));
        expect(taskProvider.error, isNull);
      });

      test('should update project successfully', () async {
        // Arrange
        await taskProvider.createProject(
          'Old Name',
          'Old Description',
          '0xFF6366F1',
        );
        final project = taskProvider.projects.first;

        // Act
        final updatedProject = project.copyWith(
          name: 'New Name',
          description: 'New Description',
        );
        await taskProvider.updateProject(updatedProject);

        // Assert
        expect(taskProvider.projects.first.name, equals('New Name'));
        expect(
          taskProvider.projects.first.description,
          equals('New Description'),
        );
        expect(taskProvider.error, isNull);
      });

      test('should delete project successfully', () async {
        // Arrange
        await taskProvider.createProject(
          'Test Project',
          'Description',
          '0xFF6366F1',
        );
        expect(taskProvider.projects.length, equals(1));

        // Act
        await taskProvider.deleteProject(taskProvider.projects.first.id);

        // Assert
        expect(taskProvider.projects.length, equals(0));
        expect(taskProvider.error, isNull);
      });

      test('should select project', () {
        // Arrange
        const name = 'Test Project';
        const description = 'Test Description';
        const color = '0xFF6366F1';

        // Act
        taskProvider.createProject(name, description, color);
        final project = taskProvider.projects.first;
        taskProvider.selectProject(project);

        // Assert
        expect(taskProvider.selectedProject, equals(project));
      });
    });

    group('Task Management', () {
      late Project testProject;

      setUp(() async {
        await taskProvider.createProject(
          'Test Project',
          'Description',
          '0xFF6366F1',
        );
        testProject = taskProvider.projects.first;
        taskProvider.selectProject(testProject);
      });

      test('should create task successfully', () async {
        // Arrange
        const title = 'Test Task';
        const description = 'Test Task Description';

        // Act
        await taskProvider.createTask(
          title,
          description,
          TaskPriority.high,
          DateTime.now().add(const Duration(days: 1)),
        );

        // Assert
        expect(taskProvider.tasks.length, equals(1));
        expect(taskProvider.tasks.first.title, equals(title));
        expect(taskProvider.tasks.first.description, equals(description));
        expect(taskProvider.tasks.first.priority, equals(TaskPriority.high));
        expect(taskProvider.error, isNull);
      });

      test('should update task successfully', () async {
        // Arrange
        await taskProvider.createTask(
          'Old Title',
          'Old Description',
          TaskPriority.low,
          null,
        );
        final task = taskProvider.tasks.first;

        // Act
        final updatedTask = task.copyWith(
          title: 'New Title',
          description: 'New Description',
          priority: TaskPriority.high,
        );
        await taskProvider.updateTask(updatedTask);

        // Assert
        expect(taskProvider.tasks.first.title, equals('New Title'));
        expect(taskProvider.tasks.first.description, equals('New Description'));
        expect(taskProvider.tasks.first.priority, equals(TaskPriority.high));
        expect(taskProvider.error, isNull);
      });

      test('should delete task successfully', () async {
        // Arrange
        await taskProvider.createTask(
          'Test Task',
          'Description',
          TaskPriority.medium,
          null,
        );
        expect(taskProvider.tasks.length, equals(1));

        // Act
        await taskProvider.deleteTask(taskProvider.tasks.first.id);

        // Assert
        expect(taskProvider.tasks.length, equals(0));
        expect(taskProvider.error, isNull);
      });

      test('should toggle task status', () async {
        // Arrange
        await taskProvider.createTask(
          'Test Task',
          'Description',
          TaskPriority.medium,
          null,
        );
        final task = taskProvider.tasks.first;
        expect(task.status, equals(TaskStatus.pending));

        // Act
        await taskProvider.toggleTaskStatus(task.id);

        // Assert
        expect(taskProvider.tasks.first.status, equals(TaskStatus.completed));
        expect(taskProvider.tasks.first.completedAt, isNotNull);
      });

      test('should filter tasks by project', () async {
        // Arrange
        await taskProvider.createProject(
          'Project 2',
          'Description',
          '0xFF8B5CF6',
        );
        final project2 = taskProvider.projects.last;

        await taskProvider.createTask(
          'Task 1',
          'Description',
          TaskPriority.medium,
          null,
        );

        taskProvider.selectProject(project2);
        await taskProvider.createTask(
          'Task 2',
          'Description',
          TaskPriority.medium,
          null,
        );

        // Act
        taskProvider.selectProject(testProject);

        // Assert
        final projectTasks = taskProvider.tasks
            .where((task) => task.projectId == testProject.id)
            .toList();
        expect(projectTasks.length, equals(1));
        expect(projectTasks.first.title, equals('Task 1'));
      });
    });

    group('AI Integration', () {
      late Project testProject;

      setUp(() async {
        await taskProvider.createProject(
          'Test Project',
          'Description',
          '0xFF6366F1',
        );
        testProject = taskProvider.projects.first;
        taskProvider.selectProject(testProject);
      });

      test('should generate tasks with AI', () async {
        // Arrange
        const prompt = 'Plan my week with 3 work tasks';

        // Act
        final generatedTasks = await taskProvider.generateTasksWithAI(prompt);

        // Assert
        expect(generatedTasks, isNotEmpty);
        expect(generatedTasks.length, greaterThan(0));
        expect(taskProvider.tasks.length, greaterThan(0));
        expect(taskProvider.error, isNull);
      });

      test('should fail AI generation without selected project', () async {
        // Arrange
        taskProvider.selectProject(null as Project);
        const prompt = 'Plan my week';

        // Act & Assert
        expect(() => taskProvider.generateTasksWithAI(prompt), throwsException);
      });
    });

    group('Data Persistence', () {
      test('should persist projects across provider instances', () async {
        // Arrange
        await taskProvider.createProject(
          'Test Project',
          'Description',
          '0xFF6366F1',
        );
        final projectCount = taskProvider.projects.length;

        // Act
        final newTaskProvider = TaskProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(newTaskProvider.projects.length, equals(projectCount));
      });

      test('should persist tasks across provider instances', () async {
        // Arrange
        await taskProvider.createProject(
          'Test Project',
          'Description',
          '0xFF6366F1',
        );
        taskProvider.selectProject(taskProvider.projects.first);
        await taskProvider.createTask(
          'Test Task',
          'Description',
          TaskPriority.medium,
          null,
        );
        final taskCount = taskProvider.tasks.length;

        // Act
        final newTaskProvider = TaskProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(newTaskProvider.tasks.length, equals(taskCount));
      });
    });

    group('Error Handling', () {
      test('should handle project creation errors', () async {
        // Arrange - Create invalid project data
        const name = '';
        const description = 'Description';
        const color = '0xFF6366F1';

        // Act
        await taskProvider.createProject(name, description, color);

        // Assert
        expect(taskProvider.error, isNotNull);
      });

      test('should handle task creation errors', () async {
        // Arrange
        await taskProvider.createProject(
          'Test Project',
          'Description',
          '0xFF6366F1',
        );
        taskProvider.selectProject(taskProvider.projects.first);

        // Act - Create task without title
        await taskProvider.createTask(
          '',
          'Description',
          TaskPriority.medium,
          null,
        );

        // Assert
        expect(taskProvider.error, isNotNull);
      });
    });
  });
}
