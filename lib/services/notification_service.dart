import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import '../models/task.dart';
import '../theme/doto_theme.dart';
import 'database_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'mark_completed') {
    final taskId = notificationResponse.payload;
    if (taskId != null && taskId.isNotEmpty) {
      final SendPort? uiSendPort = IsolateNameServer.lookupPortByName('doto_notification_action_port');
      if (uiSendPort != null) {
        uiSendPort.send(taskId);
      } else {
        final db = DatabaseService();
        await db.init();
        final nextTask = await db.markTaskCompletedById(taskId);
        final notifications = NotificationService();
        await notifications.init();
        await notifications.cancelTaskNotification(taskId);
        if (nextTask != null && nextTask.priority == TaskPriority.high && nextTask.scheduledTime != null) {
          await notifications.scheduleTaskNotification(nextTask);
        }
      }
    }
  }
}

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
        try {
          await notificationsPlugin.initialize(settings: initSettings);

          await notificationsPlugin.show(
            id: 1001,
            title: 'Daily Summary',
            body: 'You have ${todayTasks.length} tasks scheduled for today.',
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'daily_summary_channel',
                'Daily Summary',
                importance: Importance.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(),
              macOS: DarwinNotificationDetails(),
            ),
          );
        } catch (e) {
          debugPrint('Daily summary notification error: $e');
        }
      }
    }
    return Future.value(true);
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// ValueNotifier to signal task completion from notification to listening providers
  static final ValueNotifier<String?> taskCompletedFromNotification = ValueNotifier<String?>(null);

  /// ValueNotifier to signal user tapped notification body to navigate/focus task
  static final ValueNotifier<String?> selectedTaskIdFromNotification = ValueNotifier<String?>(null);

  bool _isInitialized = false;

  int _getNotificationId(String taskId) {
    return (taskId.hashCode & 0x7FFFFFFF);
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      tz.initializeTimeZones();

      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        final timeZoneName = timezoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('Could not fetch device timezone, using default: $e');
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'high_priority_task_actions',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              'mark_completed',
              'Mark Completed',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
      ];

      final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: darwinNotificationCategories,
      );

      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          final taskId = response.payload;
          if (response.actionId == 'mark_completed') {
            if (taskId != null && taskId.isNotEmpty) {
              final db = DatabaseService();
              await db.init();
              final nextTask = await db.markTaskCompletedById(taskId);
              await cancelTaskNotification(taskId);
              taskCompletedFromNotification.value = taskId;
              if (nextTask != null && nextTask.priority == TaskPriority.high && nextTask.scheduledTime != null) {
                await scheduleTaskNotification(nextTask);
              }
            }
          } else {
            // User clicked the notification body
            if (taskId != null && taskId.isNotEmpty) {
              selectedTaskIdFromNotification.value = taskId;
            }
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization failed gracefully: $e');
    }
  }

  Future<bool> requestPermissions() async {
    bool granted = false;
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? notifGranted = await androidImplementation?.requestNotificationsPermission();
      final bool? exactAlarmsGranted = await androidImplementation?.requestExactAlarmsPermission();
      granted = (notifGranted ?? true) && (exactAlarmsGranted ?? true);
    } else if (Platform.isIOS || Platform.isMacOS) {
      final bool? iosGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      granted = iosGranted ?? false;
    }
    return granted;
  }

  Future<void> scheduleDailySummaryTask() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      await Workmanager().registerPeriodicTask(
        'daily_summary_periodic',
        'dailySummary',
        frequency: const Duration(hours: 24),
        initialDelay: _calculateInitialDelayFor8PM(),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
    } catch (e) {
      debugPrint('Workmanager scheduling failed: $e');
    }
  }

  Future<void> cancelDailySummaryTask() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await Workmanager().cancelByUniqueName('daily_summary_periodic');
    } catch (e) {
      debugPrint('Workmanager cancellation failed: $e');
    }
  }

  Duration _calculateInitialDelayFor8PM() {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, 20, 0); // 8:00 PM
    if (now.isAfter(scheduled)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled.difference(now);
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.priority != TaskPriority.high || task.isCompleted || task.scheduledTime == null) {
      await cancelTaskNotification(task.id);
      return;
    }

    if (!_isInitialized) {
      await init();
    }

    const highPriorityChannelId = 'doto_high_priority_sticky_v2';
    const highPriorityChannelName = 'High Priority Tasks';
    const highPriorityChannelDesc = 'Persistent alerts for high priority scheduled tasks';

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      highPriorityChannelId,
      highPriorityChannelName,
      channelDescription: highPriorityChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      autoCancel: false,
      additionalFlags: Int32List.fromList([32, 2]),
      color: DotoSemantic.priorityHigh,
      ledColor: DotoSemantic.priorityHigh,
      ledOnMs: 1000,
      ledOffMs: 500,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'mark_completed',
          'Mark Completed',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'High Priority',
      threadIdentifier: 'doto_high_priority_tasks',
      categoryIdentifier: 'high_priority_task_actions',
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    final notifId = _getNotificationId(task.id);
    final scheduledDate = tz.TZDateTime.from(task.scheduledTime!, tz.local);

    if (task.scheduledTime!.isAfter(DateTime.now())) {
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: notifId,
          title: task.title,
          body: null,
          scheduledDate: scheduledDate,
          notificationDetails: platformChannelSpecifics,
          payload: task.id,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('Exact alarm scheduling failed/not allowed, falling back to inexact: $e');
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: notifId,
          title: task.title,
          body: null,
          scheduledDate: scheduledDate,
          notificationDetails: platformChannelSpecifics,
          payload: task.id,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } else {
      // Designated time has already passed / reached and task is still high-priority & pending
      await flutterLocalNotificationsPlugin.show(
        id: notifId,
        title: task.title,
        body: null,
        notificationDetails: platformChannelSpecifics,
        payload: task.id,
      );
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    final notifId = _getNotificationId(taskId);
    await flutterLocalNotificationsPlugin.cancel(id: notifId);
  }
}
