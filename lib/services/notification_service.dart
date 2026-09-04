import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
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
        if (nextTask != null && nextTask.scheduledTime != null) {
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
        const androidInit = AndroidInitializationSettings('ic_notification');
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
                icon: 'ic_notification',
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

  /// Why the last notification could not be posted or scheduled, or null when
  /// the most recent attempt succeeded. Surfaced in Settings so a reminder the
  /// OS silently rejected is visible instead of only reaching the debug log.
  static final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);

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
        if (timeZoneName == 'UTC' || timeZoneName == 'Etc/UTC') {
          tz.setLocalLocation(tz.UTC);
        } else {
          tz.setLocalLocation(tz.getLocation(timeZoneName));
        }
      } catch (e) {
        debugPrint('Could not fetch device timezone, using default: $e');
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');

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
              if (nextTask != null && nextTask.scheduledTime != null) {
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
      _recordFailure('initialize', e);
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

  /// Schedules (or immediately posts) the reminder for [task].
  ///
  /// Never throws: a reminder the OS rejects is recorded in [lastError], not
  /// propagated, so saving a task can never be derailed by the alarm subsystem.
  Future<void> scheduleTaskNotification(Task task) async {
    try {
      await _scheduleTaskNotification(task);
    } catch (e) {
      _recordFailure('schedule', e);
    }
  }

  Future<void> _scheduleTaskNotification(Task task) async {
    if (task.isCompleted || task.scheduledTime == null) {
      await cancelTaskNotification(task.id);
      return;
    }

    if (!_isInitialized) {
      await init();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics;
    final String priorityLabel;

    final totalSubtasks = task.subtasks.length;
    final completedSubtasks = task.subtasks.where((s) => s.isCompleted).length;
    final rawCategory = task.categoryIds.isNotEmpty ? task.categoryIds.first : 'Work';
    final primaryCategory = rawCategory.isEmpty
        ? rawCategory
        : '${rawCategory[0].toUpperCase()}${rawCategory.substring(1)}';

    switch (task.priority) {
      case TaskPriority.high:
        priorityLabel = 'High Priority';
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'doto_high_priority_sticky_v2',
          'High Priority Tasks',
          channelDescription: 'Persistent alerts for high priority scheduled tasks',
          importance: Importance.max,
          priority: Priority.max,
          ongoing: true,
          autoCancel: false,
          additionalFlags: Int32List.fromList([32, 2]),
          color: DotoSemantic.priorityHigh,
          ledColor: DotoSemantic.priorityHigh,
          showProgress: totalSubtasks > 0,
          maxProgress: totalSubtasks,
          progress: completedSubtasks,
          ledOnMs: 1000,
          ledOffMs: 500,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          onlyAlertOnce: true,
          icon: 'ic_notification',
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
        break;
      case TaskPriority.medium:
        priorityLabel = 'Medium Priority';
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'doto_medium_priority_v2',
          'Medium Priority Tasks',
          channelDescription: 'Alerts for medium priority scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: false,
          autoCancel: true,
          color: DotoSemantic.priorityMedium,
          ledColor: DotoSemantic.priorityMedium,
          showProgress: totalSubtasks > 0,
          maxProgress: totalSubtasks,
          progress: completedSubtasks,
          ledOnMs: 1000,
          ledOffMs: 500,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          onlyAlertOnce: true,
          icon: 'ic_notification',
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
        break;
      case TaskPriority.low:
        priorityLabel = 'Low Priority';
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'doto_low_priority_v2',
          'Low Priority Tasks',
          channelDescription: 'Alerts for low priority scheduled tasks',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          ongoing: false,
          autoCancel: true,
          // Quiet Minimal: no priority color wash — action buttons tint with
          // the app accent instead, the LED alone still carries the priority color.
          color: DotoSemantic.accent,
          ledColor: DotoSemantic.priorityLow,
          showProgress: totalSubtasks > 0,
          maxProgress: totalSubtasks,
          progress: completedSubtasks,
          ledOnMs: 1000,
          ledOffMs: 500,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          onlyAlertOnce: true,
          icon: 'ic_notification',
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
        break;
    }

    final metaBody = '$primaryCategory · $priorityLabel';

    final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: priorityLabel,
      threadIdentifier: 'doto_${task.priority.name}_tasks',
      categoryIdentifier: 'high_priority_task_actions',
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    final notifId = _getNotificationId(task.id);
    final scheduledDate = tz.TZDateTime.from(task.scheduledTime!, tz.local);
    final nowTz = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isAfter(nowTz)) {
      // Android 12+ refuses exact alarms unless the user granted "Alarms &
      // reminders", so ask before scheduling rather than letting the plugin
      // throw. Each attempt is isolated: a refused alarm must never take the
      // caller down with it.
      final canBeExact = await canScheduleExactAlarms();
      final mode = canBeExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      if (await _tryZonedSchedule(
        notifId: notifId,
        task: task,
        body: metaBody,
        details: platformChannelSpecifics,
        scheduledDate: scheduledDate,
        mode: mode,
      )) {
        return;
      }

      // The exact alarm was still rejected (permission revoked mid-flight, or
      // an OEM restriction). A late reminder beats no reminder.
      if (canBeExact &&
          await _tryZonedSchedule(
            notifId: notifId,
            task: task,
            body: metaBody,
            details: platformChannelSpecifics,
            scheduledDate: scheduledDate,
            mode: AndroidScheduleMode.inexactAllowWhileIdle,
          )) {
        return;
      }

      // Scheduling is unavailable entirely; if the moment has arrived while we
      // were retrying, fall through to showing it now.
      if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        await _tryShow(
          notifId: notifId,
          task: task,
          body: metaBody,
          details: platformChannelSpecifics,
        );
      }
    } else {
      // Designated time has already passed / reached and task is still pending
      await _tryShow(
        notifId: notifId,
        task: task,
        body: metaBody,
        details: platformChannelSpecifics,
      );
    }
  }

  Future<bool> _tryZonedSchedule({
    required int notifId,
    required Task task,
    required String body,
    required NotificationDetails details,
    required tz.TZDateTime scheduledDate,
    required AndroidScheduleMode mode,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notifId,
        title: task.title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        payload: task.id,
        androidScheduleMode: mode,
      );
      _recordSuccess();
      return true;
    } catch (e) {
      _recordFailure('zonedSchedule (${mode.name})', e);
      return false;
    }
  }

  Future<bool> _tryShow({
    required int notifId,
    required Task task,
    required String body,
    required NotificationDetails details,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        id: notifId,
        title: task.title,
        body: body,
        notificationDetails: details,
        payload: task.id,
      );
      _recordSuccess();
      return true;
    } catch (e) {
      _recordFailure('show', e);
      return false;
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    final notifId = _getNotificationId(taskId);
    try {
      await flutterLocalNotificationsPlugin.cancel(id: notifId);
    } catch (e) {
      _recordFailure('cancel', e);
    }
  }

  /// Whether the OS currently lets us set exact alarms. Android 12+ gates this
  /// behind the "Alarms & reminders" special access screen; everywhere else
  /// exact scheduling is always available.
  Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    try {
      final android = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await android?.canScheduleExactNotifications() ?? true;
    } catch (e) {
      debugPrint('canScheduleExactNotifications failed: $e');
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    try {
      final android = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    } catch (e) {
      debugPrint('areNotificationsEnabled failed: $e');
      return false;
    }
  }

  Future<int> pendingNotificationCount() async {
    try {
      final pending =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return pending.length;
    } catch (e) {
      debugPrint('pendingNotificationRequests failed: $e');
      return -1;
    }
  }

  /// Posts a notification immediately on the medium-priority channel, so the
  /// delivery path can be verified without waiting for a scheduled task.
  Future<String?> sendTestNotification() async {
    if (!_isInitialized) {
      await init();
    }
    try {
      await flutterLocalNotificationsPlugin.show(
        id: 9999,
        title: 'DoTo reminders are working',
        body: 'Test · this is what a task reminder looks like.',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'doto_medium_priority_v2',
            'Medium Priority Tasks',
            channelDescription: 'Alerts for medium priority scheduled tasks',
            importance: Importance.high,
            priority: Priority.high,
            color: DotoSemantic.accent,
            icon: 'ic_notification',
            visibility: NotificationVisibility.public,
          ),
          iOS: const DarwinNotificationDetails(),
          macOS: const DarwinNotificationDetails(),
        ),
      );
      _recordSuccess();
      return null;
    } catch (e) {
      _recordFailure('test show', e);
      return _describe(e);
    }
  }

  void _recordSuccess() {
    if (lastError.value != null) {
      lastError.value = null;
    }
  }

  void _recordFailure(String stage, Object error) {
    final message = '$stage: ${_describe(error)}';
    debugPrint('Notification $message');
    lastError.value = message;
  }

  String _describe(Object error) {
    if (error is PlatformException) {
      return '[${error.code}] ${error.message ?? ''}'.trim();
    }
    return error.toString();
  }
}
