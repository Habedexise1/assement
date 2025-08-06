import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Initialize settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Android permissions are handled automatically
    // iOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific task
    print('Notification tapped: ${response.payload}');
  }

  // Schedule notification for task due date
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.dueDate == null) return;

    final id = task.id.hashCode;
    final title = 'Task Due Soon';
    final body = '${task.title} is due ${_getDueDateText(task.dueDate!)}';

    // Schedule notification 1 hour before due date
    final scheduledDate = task.dueDate!.subtract(const Duration(hours: 1));

    if (scheduledDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task due dates',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: task.id,
      );
    }

    // Schedule notification on due date
    await _notifications.zonedSchedule(
      id + 1,
      'Task Due Today',
      '${task.title} is due today!',
      tz.TZDateTime.from(task.dueDate!, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_due',
          'Task Due Today',
          channelDescription: 'Notifications for tasks due today',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: task.id,
    );
  }

  // Schedule notification for overdue tasks
  Future<void> scheduleOverdueReminder(Task task) async {
    if (task.dueDate == null || !task.isOverdue) return;

    final id = task.id.hashCode + 2;
    final overdueDays = DateTime.now().difference(task.dueDate!).inDays;

    await _notifications.zonedSchedule(
      id,
      'Task Overdue',
      '${task.title} is ${overdueDays} day${overdueDays > 1 ? 's' : ''} overdue',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_overdue',
          'Overdue Tasks',
          channelDescription: 'Notifications for overdue tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: task.id,
    );
  }

  // Cancel notifications for a specific task
  Future<void> cancelTaskNotifications(String taskId) async {
    final id = taskId.hashCode;
    await _notifications.cancel(id);
    await _notifications.cancel(id + 1);
    await _notifications.cancel(id + 2);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification from TaskMaster AI',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  String _getDueDateText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'very soon';
    }
  }
}
