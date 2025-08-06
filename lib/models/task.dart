import 'package:hive/hive.dart';

part 'task.g.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, readyForQA, completed, overdue }

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String projectId;

  @HiveField(4)
  final String userId;

  @HiveField(5)
  final TaskPriority priority;

  @HiveField(6)
  final TaskStatus status;

  @HiveField(7)
  final DateTime? dueDate;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final DateTime? completedAt;

  @HiveField(11)
  final List<String> tags;

  @HiveField(12)
  final bool isRecurring;

  @HiveField(13)
  final String? recurringPattern;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.userId,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.tags = const [],
    this.isRecurring = false,
    this.recurringPattern,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      projectId: json['project_id'],
      userId: json['user_id'],
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      isRecurring: json['is_recurring'] ?? false,
      recurringPattern: json['recurring_pattern'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'project_id': projectId,
      'user_id': userId,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'tags': tags,
      'is_recurring': isRecurring,
      'recurring_pattern': recurringPattern,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? userId,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? tags,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && now.month == due.month && now.day == due.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final due = dueDate!;
    return tomorrow.year == due.year &&
        tomorrow.month == due.month &&
        tomorrow.day == due.day;
  }
}
