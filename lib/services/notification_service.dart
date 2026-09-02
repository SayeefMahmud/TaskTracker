import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'dart:io';
import '../models/task.dart';
import 'database_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'dailySummary') {
      final db = DatabaseService();
      await db.init();
      
      final tasks = db.getTasks();
      final now = DateTime.now();
      final todayTasks = tasks.where((t) => 
        !t.isCompleted && 
        t.scheduledTime != null && 
        t.scheduledTime!.year == now.year && 
        t.scheduledTime!.month == now.month && 
        t.scheduledTime!.day == now.day
      ).toList();

      if (todayTasks.isNotEmpty) {
        final notificationsPlugin = FlutterLocalNotificationsPlugin();
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosInit = DarwinInitializationSettings();
        const initSettings = InitializationSettings(
          android: androidInit, 
          iOS: iosInit,
          macOS: iosInit,
        );
        await notificationsPlugin.initialize(settings: initSettings);

        await notificationsPlugin.show(
          id: 1001,
          title: 'Your Daily Summary',
          body: 'You have ${todayTasks.length} tasks scheduled for today.',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails('daily_summary_channel', 'Daily Summary', importance: Importance.high),
            iOS: DarwinNotificationDetails(),
            macOS: DarwinNotificationDetails(),
          ),
        );
      }
    }
    return Future.value(true);
  });
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      await scheduleDailySummaryTask();
    }
  }

  Future<void> scheduleDailySummaryTask() async {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, 7, 0);
    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }
    final delay = target.difference(now);

    await Workmanager().registerPeriodicTask(
      'daily_summary_task',
      'dailySummary',
      frequency: const Duration(days: 1),
      initialDelay: delay,
    );
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.scheduledTime == null || task.scheduledTime!.isBefore(DateTime.now())) return;

    final androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    final iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: task.id.hashCode,
      title: task.title,
      body: task.description ?? 'Task Reminder',
      scheduledDate: tz.TZDateTime.from(task.scheduledTime!, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskNotification(String taskId) async {
    await flutterLocalNotificationsPlugin.cancel(id: taskId.hashCode);
  }
}
