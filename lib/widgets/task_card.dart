import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return AppConstants.lowPriorityColor;
      case TaskPriority.medium:
        return AppConstants.mediumPriorityColor;
      case TaskPriority.high:
        return AppConstants.highPriorityColor;
    }
  }

  String _getPriorityText() {
    switch (task.priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  String _getDueDateText() {
    if (task.dueDate == null) return 'No due date';

    final due = task.dueDate!;

    if (task.isDueToday) {
      return 'Today at ${DateFormat('HH:mm').format(due)}';
    } else if (task.isDueTomorrow) {
      return 'Tomorrow at ${DateFormat('HH:mm').format(due)}';
    } else if (task.isOverdue) {
      return 'Overdue - ${DateFormat('MMM dd, HH:mm').format(due)}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(due);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Edit task
            },
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              taskProvider.deleteTask(task.id);
            },
            backgroundColor: AppConstants.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: AppConstants.cardShadow,
          border: task.isOverdue
              ? Border.all(color: AppConstants.errorColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            // Checkbox
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return Checkbox(
                  value: task.status == TaskStatus.completed,
                  onChanged: (value) {
                    taskProvider.toggleTaskStatus(task.id);
                  },
                  activeColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                );
              },
            ),

            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: task.status == TaskStatus.completed
                                ? Colors.grey[600]
                                : Colors.black87,
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingS,
                          vertical: AppConstants.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusS,
                          ),
                        ),
                        child: Text(
                          _getPriorityText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppConstants.paddingS),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: task.isOverdue
                            ? AppConstants.errorColor
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: AppConstants.paddingXS),
                      Text(
                        _getDueDateText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isOverdue
                              ? AppConstants.errorColor
                              : Colors.grey[600],
                          fontWeight: task.isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (task.isOverdue) ...[
                        const SizedBox(width: AppConstants.paddingS),
                        GestureDetector(
                          onTap: () async {
                            final taskProvider = Provider.of<TaskProvider>(
                              context,
                              listen: false,
                            );
                            final newTime = await taskProvider
                                .suggestNewTimeForTask(task);
                            if (newTime != null && context.mounted) {
                              // Show suggestion dialog
                              _showRescheduleDialog(context, newTime);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingS,
                              vertical: AppConstants.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusS,
                              ),
                            ),
                            child: const Text(
                              'Reschedule',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, DateTime newTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Suggestion'),
        content: Text(
          'Would you like to reschedule this task to ${DateFormat('MMM dd, HH:mm').format(newTime)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              final updatedTask = task.copyWith(dueDate: newTime);
              taskProvider.updateTask(updatedTask);
              Navigator.of(context).pop();
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }
}
