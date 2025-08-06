import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:assesment/models/task.dart';
import 'package:assesment/models/project.dart';
import 'package:assesment/utils/constants.dart';

void main() {
  group('Simple Model Tests', () {
    test('Task model should work correctly', () {
      // Arrange
      final task = Task(
        id: 'test_task_1',
        title: 'Test Task',
        description: 'Test Description',
        projectId: 'test_project_1',
        userId: 'test_user_1',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(task.id, equals('test_task_1'));
      expect(task.title, equals('Test Task'));
      expect(task.priority, equals(TaskPriority.high));
      expect(task.status, equals(TaskStatus.pending));
      expect(task.isOverdue, isFalse);
    });

    test('Task should be overdue when due date is in the past', () {
      // Arrange
      final task = Task(
        id: 'test_task_2',
        title: 'Overdue Task',
        description: 'Overdue Description',
        projectId: 'test_project_1',
        userId: 'test_user_1',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(task.isOverdue, isTrue);
    });

    test('Project model should work correctly', () {
      // Arrange
      final project = Project(
        id: 'test_project_1',
        name: 'Test Project',
        description: 'Test Project Description',
        color: '0xFF6366F1',
        userId: 'test_user_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(project.id, equals('test_project_1'));
      expect(project.name, equals('Test Project'));
      expect(project.color, equals('0xFF6366F1'));
    });

    test('Project copyWith should work correctly', () {
      // Arrange
      final originalProject = Project(
        id: 'test_project_1',
        name: 'Original Name',
        description: 'Original Description',
        color: '0xFF6366F1',
        userId: 'test_user_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final updatedProject = originalProject.copyWith(
        name: 'Updated Name',
        description: 'Updated Description',
      );

      // Assert
      expect(updatedProject.id, equals(originalProject.id));
      expect(updatedProject.name, equals('Updated Name'));
      expect(updatedProject.description, equals('Updated Description'));
      expect(updatedProject.color, equals(originalProject.color));
    });

    test('Task copyWith should work correctly', () {
      // Arrange
      final originalTask = Task(
        id: 'test_task_1',
        title: 'Original Title',
        description: 'Original Description',
        projectId: 'test_project_1',
        userId: 'test_user_1',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final updatedTask = originalTask.copyWith(
        title: 'Updated Title',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      );

      // Assert
      expect(updatedTask.id, equals(originalTask.id));
      expect(updatedTask.title, equals('Updated Title'));
      expect(updatedTask.priority, equals(TaskPriority.high));
      expect(updatedTask.status, equals(TaskStatus.completed));
      expect(updatedTask.description, equals(originalTask.description));
    });

    test('AppConstants should have correct values', () {
      // Assert
      expect(AppConstants.appName, equals('TaskMaster AI'));
      expect(AppConstants.primaryColor, isA<Color>());
      expect(AppConstants.projectColors, isNotEmpty);
      expect(AppConstants.projectColors.length, greaterThan(0));
    });

    test('Color parsing utility should work correctly', () {
      // Test hex color parsing
      final hexColor = AppConstants.parseColor('0xFF6366F1');
      expect(hexColor, isA<Color>());

      // Test invalid color parsing (should return primary color)
      final invalidColor = AppConstants.parseColor('invalid_color');
      expect(invalidColor, equals(AppConstants.primaryColor));
    });

    test('Task priority enum should have correct values', () {
      // Assert
      expect(TaskPriority.values.length, equals(3));
      expect(TaskPriority.values.contains(TaskPriority.low), isTrue);
      expect(TaskPriority.values.contains(TaskPriority.medium), isTrue);
      expect(TaskPriority.values.contains(TaskPriority.high), isTrue);
    });

    test('Task status enum should have correct values', () {
      // Assert
      expect(TaskStatus.values.length, equals(4));
      expect(TaskStatus.values.contains(TaskStatus.pending), isTrue);
      expect(TaskStatus.values.contains(TaskStatus.inProgress), isTrue);
      expect(TaskStatus.values.contains(TaskStatus.completed), isTrue);
      expect(TaskStatus.values.contains(TaskStatus.overdue), isTrue);
    });
  });
} 