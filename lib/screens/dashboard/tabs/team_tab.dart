import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import '../../../services/user_management_service.dart';
import '../../../providers/task_provider.dart';

class TeamTab extends StatefulWidget {
  const TeamTab({super.key});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  final UserManagementService _userManagementService = UserManagementService();
  List<User> _teamMembers = [];
  Map<String, int> _teamStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allUsers = await _userManagementService.getAllUsers();
      // Filter to show only managers and users (not admins) as team members
      final teamMembers = allUsers
          .where((user) => user.role != 'admin')
          .toList();

      final stats = await _userManagementService.getUserStats();

      setState(() {
        _teamMembers = teamMembers;
        _teamStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load team members: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Team Management'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeamMembers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Team Stats
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Team Members',
                          '${_teamMembers.length}',
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          'Managers',
                          '${_teamStats['managers'] ?? 0}',
                          Icons.manage_accounts,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          'Active Users',
                          '${_teamStats['users'] ?? 0}',
                          Icons.person,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                // Team Members List
                Expanded(
                  child: _teamMembers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: AppConstants.paddingM),
                              Text(
                                'No team members found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingS),
                              Text(
                                'Team members will appear here when they register',
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
                          itemCount: _teamMembers.length,
                          itemBuilder: (context, index) {
                            final member = _teamMembers[index];
                            return _buildTeamMemberCard(member);
                          },
                        ),
                ),
              ],
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
      padding: const EdgeInsets.all(AppConstants.paddingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(User member) {
    final roleColor = _getRoleColor(member.role);
    final statusColor = Colors.green; // All users are considered online for now

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: AppConstants.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.paddingM),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          child: Text(
            member.name[0].toUpperCase(),
            style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingXS),
            Text(member.email, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: AppConstants.paddingXS),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    _getRoleDisplayName(member.role).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              'Joined: ${_formatDate(member.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'view_profile':
                _showMemberProfile(context, member);
                break;
              case 'assign_task':
                _showAssignTaskDialog(context, member);
                break;
              case 'send_message':
                _showMessageDialog(context, member);
                break;
              case 'edit':
                _showEditMemberDialog(context, member);
                break;
              case 'remove':
                _showRemoveMemberDialog(context, member);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: AppConstants.paddingS),
                  Text('View Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign_task',
              child: Row(
                children: [
                  Icon(Icons.assignment, size: 20),
                  SizedBox(width: AppConstants.paddingS),
                  Text('Assign Task'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'send_message',
              child: Row(
                children: [
                  Icon(Icons.message, size: 20),
                  SizedBox(width: AppConstants.paddingS),
                  Text('Send Message'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: AppConstants.paddingS),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, size: 20, color: Colors.red),
                  SizedBox(width: AppConstants.paddingS),
                  Text('Remove from Team', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'user':
      default:
        return 'Team Member';
    }
  }

  void _showMemberProfile(BuildContext context, User member) {
    showDialog(
      context: context,
      builder: (context) => MemberProfileDialog(member: member),
    );
  }

  void _showAssignTaskDialog(BuildContext context, User member) {
    showDialog(
      context: context,
      builder: (context) => AssignTaskDialog(member: member),
    );
  }

  void _showMessageDialog(BuildContext context, User member) {
    showDialog(
      context: context,
      builder: (context) => MessageDialog(member: member),
    );
  }

  void _showEditMemberDialog(BuildContext context, User member) {
    showDialog(
      context: context,
      builder: (context) => EditMemberDialog(member: member),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, User member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Team'),
        content: Text(
          'Are you sure you want to remove ${member.name} from the team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, this would update the user's team status
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${member.name} has been removed from the team',
                  ),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class MemberProfileDialog extends StatelessWidget {
  final User member;

  const MemberProfileDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final assignedTasks = taskProvider.tasks
            .where((task) => task.userId == member.id)
            .toList();

        final completedTasks = assignedTasks
            .where((task) => task.status == TaskStatus.completed)
            .length;
        final pendingTasks = assignedTasks
            .where((task) => task.status == TaskStatus.pending)
            .length;
        final inProgressTasks = assignedTasks
            .where((task) => task.status == TaskStatus.inProgress)
            .length;

        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getRoleColor(member.role),
                child: Text(
                  member.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: Text(
                  '${member.name}\'s Profile',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email: ${member.email}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: AppConstants.paddingXS),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(member.role),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusS,
                              ),
                            ),
                            child: Text(
                              member.role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Joined: ${_formatDate(member.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Task Statistics
                const Text(
                  'Task Statistics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.paddingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildTaskStatCard(
                        'Total',
                        '${assignedTasks.length}',
                        Icons.assignment,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: _buildTaskStatCard(
                        'Completed',
                        '$completedTasks',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: _buildTaskStatCard(
                        'Pending',
                        '$pendingTasks',
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Recent Tasks
                if (assignedTasks.isNotEmpty) ...[
                  const Text(
                    'Recent Tasks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: assignedTasks.take(5).length,
                      itemBuilder: (context, index) {
                        final task = assignedTasks[index];
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.paddingS,
                          ),
                          padding: const EdgeInsets.all(AppConstants.paddingS),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusS,
                            ),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getTaskStatusIcon(task.status),
                                color: _getTaskStatusColor(task.status),
                                size: 16,
                              ),
                              const SizedBox(width: AppConstants.paddingS),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task.priority),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.priority.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: const Center(
                      child: Text(
                        'No tasks assigned yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.readyForQA:
        return Colors.purple;
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.overdue:
        return Colors.red;
    }
  }

  IconData _getTaskStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.pending;
      case TaskStatus.readyForQA:
        return Icons.verified;
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.overdue:
        return Icons.warning;
    }
  }

  Widget _buildTaskStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AssignTaskDialog extends StatefulWidget {
  final User member;

  const AssignTaskDialog({super.key, required this.member});

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Project? _selectedProject;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final projects = taskProvider.projects;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.assignment, color: AppConstants.primaryColor),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: Text(
                  'Assign Task to ${widget.member.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Selection
                  const Text(
                    'Project',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppConstants.paddingXS),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingS,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: DropdownButtonFormField<Project>(
                      value: _selectedProject,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Select a project',
                      ),
                      items: projects.map((project) {
                        return DropdownMenuItem(
                          value: project,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppConstants.parseColor(project.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingS),
                              Flexible(
                                child: Text(
                                  project.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (Project? value) {
                        setState(() {
                          _selectedProject = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a project';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Task Title
                  const Text(
                    'Task Title',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppConstants.paddingXS),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter task title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Task Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppConstants.paddingXS),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Enter task description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Priority and Due Date Row
                  Row(
                    children: [
                      // Priority
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priority',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingXS),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingS,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusM,
                                ),
                              ),
                              child: DropdownButtonFormField<TaskPriority>(
                                value: _selectedPriority,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                items: TaskPriority.values.map((priority) {
                                  return DropdownMenuItem(
                                    value: priority,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          color: _getPriorityColor(priority),
                                          size: 16,
                                        ),
                                        const SizedBox(
                                          width: AppConstants.paddingS,
                                        ),
                                        Text(priority.name.toUpperCase()),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (TaskPriority? value) {
                                  setState(() {
                                    _selectedPriority =
                                        value ?? TaskPriority.medium;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      // Due Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Due Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingXS),
                            InkWell(
                              onTap: _selectDueDate,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingS,
                                  vertical: AppConstants.paddingS,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusM,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(
                                      width: AppConstants.paddingS,
                                    ),
                                    Expanded(
                                      child: Text(
                                        _selectedDueDate != null
                                            ? _formatDate(_selectedDueDate!)
                                            : 'Select date',
                                        style: TextStyle(
                                          color: _selectedDueDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _assignTask(context, taskProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Assign Task'),
            ),
          ],
        );
      },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _assignTask(
    BuildContext context,
    TaskProvider taskProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await taskProvider.createTaskForUser(
        _titleController.text,
        _descriptionController.text,
        _selectedProject!.id,
        widget.member.id, // Assign to the selected team member
        _selectedPriority,
        _selectedDueDate,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task assigned to ${widget.member.name} successfully',
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign task: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class MessageDialog extends StatelessWidget {
  final User member;

  const MessageDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Message to ${member.name}'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Messaging functionality would be implemented here.')],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message sent successfully'),
                backgroundColor: AppConstants.successColor,
              ),
            );
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class EditMemberDialog extends StatelessWidget {
  final User member;

  const EditMemberDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${member.name}'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Edit member functionality would be implemented here.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member updated successfully'),
                backgroundColor: AppConstants.successColor,
              ),
            );
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
