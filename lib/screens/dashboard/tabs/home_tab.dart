import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/task_card.dart';
import '../../../widgets/stats_card.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import '../../../models/user.dart';
import '../../../services/user_management_service.dart';
import 'user_tasks_tab.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer2<TaskProvider, AuthProvider>(
          builder: (context, taskProvider, authProvider, child) {
            if (taskProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppConstants.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Welcome back, ${authProvider.currentUser?.name ?? 'User'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppConstants.primaryColor,
                            AppConstants.secondaryColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Stats Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Total Tasks',
                                value: taskProvider.tasks.length.toString(),
                                icon: Icons.task_alt,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingM),
                            Expanded(
                              child: StatsCard(
                                title: 'Completed',
                                value: taskProvider.tasks
                                    .where(
                                      (task) =>
                                          task.status == TaskStatus.completed,
                                    )
                                    .length
                                    .toString(),
                                icon: Icons.check_circle,
                                color: AppConstants.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Overdue',
                                value: taskProvider.overdueTasks.length
                                    .toString(),
                                icon: Icons.warning,
                                color: AppConstants.errorColor,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingM),
                            Expanded(
                              child: StatsCard(
                                title: 'High Priority',
                                value: taskProvider.highPriorityTasks.length
                                    .toString(),
                                icon: Icons.priority_high,
                                color: AppConstants.warningColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Today's Tasks
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Today\'s Tasks',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const UserTasksTab(),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                      ],
                    ),
                  ),
                ),

                // Tasks List
                if (taskProvider.todayTasks.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.paddingXL),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.task_alt, size: 64, color: Colors.grey),
                            SizedBox(height: AppConstants.paddingM),
                            Text(
                              'No tasks for today',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppConstants.paddingS),
                            Text(
                              'Create a new task or check your upcoming tasks',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = taskProvider.todayTasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingL,
                          vertical: AppConstants.paddingS,
                        ),
                        child: TaskCard(task: task),
                      );
                    }, childCount: taskProvider.todayTasks.length),
                  ),

                // My Assigned Tasks
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Assigned Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                      ],
                    ),
                  ),
                ),

                // My Assigned Tasks List
                SliverToBoxAdapter(
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final currentUser = authProvider.currentUser;
                      final myTasks = taskProvider.tasks
                          .where((task) => task.userId == currentUser?.id)
                          .toList();

                      if (myTasks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingL),
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppConstants.paddingL,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                              boxShadow: AppConstants.cardShadow,
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: AppConstants.paddingM),
                                  Text(
                                    'No tasks assigned to you',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.paddingS),
                                  Text(
                                    'Tasks assigned to you will appear here',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingL,
                        ),
                        child: Column(
                          children: myTasks.map((task) {
                            final project = taskProvider.projects.firstWhere(
                              (p) => p.id == task.projectId,
                              orElse: () => Project(
                                id: 'unknown',
                                name: 'Unknown Project',
                                description: '',
                                color: '0xFF6366F1',
                                userId: 'unknown',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                            );

                            return _buildMyTaskCard(
                              context,
                              task,
                              project,
                              taskProvider,
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),

                // Overdue Tasks
                if (taskProvider.overdueTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overdue Tasks',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.errorColor,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = taskProvider.overdueTasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingL,
                          vertical: AppConstants.paddingS,
                        ),
                        child: TaskCard(task: task),
                      );
                    }, childCount: taskProvider.overdueTasks.length),
                  ),
                ],

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppConstants.paddingXL),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () {
          // Navigate to create task
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyTaskCard(
    BuildContext context,
    Task task,
    Project project,
    TaskProvider taskProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Column(
        children: [
          // Task header
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                // Project color indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppConstants.parseColor(project.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingS),
                // Task title and project
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    task.priority.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Task details
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
            ),
            child: Column(
              children: [
                // Status and due date
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.dueDate != null)
                            Text(
                              'Due: ${_formatDate(task.dueDate!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusS,
                        ),
                        border: Border.all(
                          color: _getStatusColor(task.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusDisplayName(task.status),
                        style: TextStyle(
                          color: _getStatusColor(task.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.paddingM),

                // Status change buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusButton(
                        'Pending',
                        TaskStatus.pending,
                        task.status == TaskStatus.pending,
                        () => _updateTaskStatus(
                          context,
                          task,
                          TaskStatus.pending,
                          taskProvider,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: _buildStatusButton(
                        'In Progress',
                        TaskStatus.inProgress,
                        task.status == TaskStatus.inProgress,
                        () => _updateTaskStatus(
                          context,
                          task,
                          TaskStatus.inProgress,
                          taskProvider,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: _buildStatusButton(
                        'Ready for QA',
                        TaskStatus.readyForQA,
                        task.status == TaskStatus.readyForQA,
                        () => _updateTaskStatus(
                          context,
                          task,
                          TaskStatus.readyForQA,
                          taskProvider,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: _buildStatusButton(
                        'Completed',
                        TaskStatus.completed,
                        task.status == TaskStatus.completed,
                        () => _updateTaskStatus(
                          context,
                          task,
                          TaskStatus.completed,
                          taskProvider,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.paddingM),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    String label,
    TaskStatus status,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingS,
          vertical: AppConstants.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isActive ? _getStatusColor(status) : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(
            color: isActive ? _getStatusColor(status) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppConstants.lowPriorityColor;
      case TaskPriority.medium:
        return AppConstants.mediumPriorityColor;
      case TaskPriority.high:
        return AppConstants.highPriorityColor;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.readyForQA:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.overdue:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.readyForQA:
        return 'Ready for QA';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _updateTaskStatus(
    BuildContext context,
    Task task,
    TaskStatus newStatus,
    TaskProvider taskProvider,
  ) async {
    try {
      final updatedTask = task.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
      );

      await taskProvider.updateTask(updatedTask);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task status updated to ${_getStatusDisplayName(newStatus)}',
          ),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update task status: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }
}
