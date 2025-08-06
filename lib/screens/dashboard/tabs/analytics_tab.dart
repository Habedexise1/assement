import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import '../../../models/user.dart';
import '../../../services/user_management_service.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  final UserManagementService _userManagementService = UserManagementService();
  List<User> _users = [];
  String _selectedFilter =
      'all'; // all, pending, inProgress, readyForQA, completed, overdue
  String _selectedProject = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userManagementService.getAllUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Task Analytics'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer2<TaskProvider, AuthProvider>(
        builder: (context, taskProvider, authProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = authProvider.currentUser;
          final projects = taskProvider.projects;
          final allTasks = taskProvider.tasks;

          // Filter tasks based on selected filter
          final filteredTasks = _filterTasks(allTasks, projects);

          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: AppConstants.paddingS),
                      _buildFilterChip('Pending', 'pending'),
                      const SizedBox(width: AppConstants.paddingS),
                      _buildFilterChip('In Progress', 'inProgress'),
                      const SizedBox(width: AppConstants.paddingS),
                      _buildFilterChip('Ready for QA', 'readyForQA'),
                      const SizedBox(width: AppConstants.paddingS),
                      _buildFilterChip('Completed', 'completed'),
                      const SizedBox(width: AppConstants.paddingS),
                      _buildFilterChip('Overdue', 'overdue'),
                    ],
                  ),
                ),
              ),

              // Task statistics
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingL,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Tasks',
                        '${filteredTasks.length}',
                        Icons.assignment,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: _buildStatCard(
                        'My Tasks',
                        '${filteredTasks.where((t) => t.userId == currentUser?.id).length}',
                        Icons.person,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: _buildStatCard(
                        'Overdue',
                        '${filteredTasks.where((t) => t.status == TaskStatus.overdue).length}',
                        Icons.warning,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingM),

              // Tasks list
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppConstants.paddingM),
                            Text(
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingS),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingL,
                        ),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          final assignedUser = _users.firstWhere(
                            (user) => user.id == task.userId,
                            orElse: () => User(
                              id: 'unknown',
                              email: 'unknown@example.com',
                              name: 'Unknown User',
                              createdAt: DateTime.now(),
                              role: 'user',
                            ),
                          );
                          final project = projects.firstWhere(
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

                          return _buildTaskCard(
                            task,
                            assignedUser,
                            project,
                            currentUser,
                            taskProvider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks, List<Project> projects) {
    List<Task> filtered = tasks;

    // Filter by status
    if (_selectedFilter != 'all') {
      filtered = filtered.where((task) {
        switch (_selectedFilter) {
          case 'pending':
            return task.status == TaskStatus.pending;
          case 'inProgress':
            return task.status == TaskStatus.inProgress;
          case 'readyForQA':
            return task.status == TaskStatus.readyForQA;
          case 'completed':
            return task.status == TaskStatus.completed;
          case 'overdue':
            return task.status == TaskStatus.overdue;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by project
    if (_selectedProject != 'all') {
      filtered = filtered
          .where((task) => task.projectId == _selectedProject)
          .toList();
    }

    return filtered;
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    Task task,
    User assignedUser,
    Project project,
    User? currentUser,
    TaskProvider taskProvider,
  ) {
    final isAssignedToMe = task.userId == currentUser?.id;
    final canChangeStatus =
        isAssignedToMe ||
        currentUser?.role == 'manager' ||
        currentUser?.role == 'admin';

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
                // Assigned user
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _getRoleColor(assignedUser.role),
                      child: Text(
                        assignedUser.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned to ${assignedUser.name}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

                // Status change buttons (only for assigned user or managers/admins)
                if (canChangeStatus) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusButton(
                          'Pending',
                          TaskStatus.pending,
                          task.status == TaskStatus.pending,
                          () => _updateTaskStatus(
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
                            task,
                            TaskStatus.completed,
                            taskProvider,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.green;
      case 'user':
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _updateTaskStatus(
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task status updated to ${_getStatusDisplayName(newStatus)}',
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task status: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Text('Filter options will be implemented here')],
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
}
