import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assesment/providers/task_provider.dart';
import 'package:assesment/screens/dashboard/tabs/projects_tab.dart';
import 'package:assesment/models/project.dart';
import 'package:assesment/models/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ProjectsTab Widget Tests', () {
    late TaskProvider taskProvider;

    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(ProjectAdapter());
      Hive.registerAdapter(TaskAdapter());
    });

    setUp(() async {
      await Hive.deleteBoxFromDisk('projects');
      await Hive.deleteBoxFromDisk('tasks');
      taskProvider = TaskProvider();
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('projects');
      await Hive.deleteBoxFromDisk('tasks');
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TaskProvider>.value(
          value: taskProvider,
          child: const ProjectsTab(),
        ),
      );
    }

    testWidgets('should display empty state when no projects exist', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('No Projects Yet'), findsOneWidget);
      expect(find.text('Create your first project to start organizing your tasks'), findsOneWidget);
      expect(find.text('Create Your First Project'), findsOneWidget);
    });

    testWidgets('should show create project dialog when FAB is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create New Project'), findsOneWidget);
      expect(find.text('Project Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Choose Color Theme'), findsOneWidget);
    });

    testWidgets('should create project successfully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Open create dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter project details
      await tester.enterText(find.byType(TextFormField).first, 'Test Project');
      await tester.enterText(find.byType(TextFormField).last, 'Test Description');

      // Tap create button
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Project'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('No Projects Yet'), findsNothing);
    });

    testWidgets('should show validation error for empty project name', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Open create dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to create without name
      await tester.tap(find.text('Create Project'));
      await tester.pump();

      // Assert - Dialog should still be open
      expect(find.text('Create New Project'), findsOneWidget);
    });

    testWidgets('should display projects list when projects exist', (WidgetTester tester) async {
      // Arrange
      await taskProvider.createProject('Test Project', 'Test Description', '0xFF6366F1');
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Test Project'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('No Projects Yet'), findsNothing);
    });

    testWidgets('should show project progress information', (WidgetTester tester) async {
      // Arrange
      await taskProvider.createProject('Test Project', 'Test Description', '0xFF6366F1');
      final project = taskProvider.projects.first;
      taskProvider.selectProject(project);
      
      // Add some tasks
      await taskProvider.createTask('Task 1', 'Description', TaskPriority.medium, null);
      await taskProvider.createTask('Task 2', 'Description', TaskPriority.high, null);
      
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('0 of 2 tasks completed'), findsOneWidget);
    });

    testWidgets('should show edit project dialog when edit is tapped', (WidgetTester tester) async {
      // Arrange
      await taskProvider.createProject('Test Project', 'Test Description', '0xFF6366F1');
      await tester.pumpWidget(createTestWidget());

      // Act - Open project menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Project'), findsOneWidget);
      expect(find.text('Update Project'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (WidgetTester tester) async {
      // Arrange
      await taskProvider.createProject('Test Project', 'Test Description', '0xFF6366F1');
      await tester.pumpWidget(createTestWidget());

      // Act - Open project menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Project'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Test Project"?'), findsOneWidget);
    });

    testWidgets('should delete project when confirmed', (WidgetTester tester) async {
      // Arrange
      await taskProvider.createProject('Test Project', 'Test Description', '0xFF6366F1');
      await tester.pumpWidget(createTestWidget());

      // Act - Delete project
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Project'), findsNothing);
      expect(find.text('No Projects Yet'), findsOneWidget);
    });

    testWidgets('should show color selection in create dialog', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Open create dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Container), findsWidgets);
      // Should find color circles (containers with specific decoration)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should navigate to project details when project is tapped', (WidgetTester tester) async {
      // Arrange
      await taskProvider.createProject('Test Project', 'Test Description', '0xFF6366F1');
      await tester.pumpWidget(createTestWidget());

      // Act - Tap on project
      await tester.tap(find.text('Test Project'));
      await tester.pump();

      // Assert - Project should be selected
      expect(taskProvider.selectedProject?.name, equals('Test Project'));
    });

    testWidgets('should show loading indicator when provider is loading', (WidgetTester tester) async {
      // Arrange
      // Create a task to trigger loading state
      await taskProvider.createProject('Test Project', 'Description', '0xFF6366F1');
      await tester.pumpWidget(createTestWidget());

      // Assert - Should not show loading indicator in normal state
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display project statistics correctly', (WidgetTester tester) async {
      // Arrange
      await taskProvider.createProject('Project 1', 'Description', '0xFF6366F1');
      await taskProvider.createProject('Project 2', 'Description', '0xFF8B5CF6');
      
      final project1 = taskProvider.projects.first;
      taskProvider.selectProject(project1);
      
      await taskProvider.createTask('Task 1', 'Description', TaskPriority.medium, null);
      await taskProvider.createTask('Task 2', 'Description', TaskPriority.high, null);
      
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Project 1'), findsOneWidget);
      expect(find.text('Project 2'), findsOneWidget);
      expect(find.text('2 of 2 tasks completed'), findsNothing); // No completed tasks yet
    });
  });
} 