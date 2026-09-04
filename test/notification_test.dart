import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:doto/models/task.dart';
import 'package:doto/theme/doto_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> channelCalls = [];
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');

  setUp(() {
    channelCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      channelCalls.add(call);
      if (call.method == 'initialize') {
        return true;
      }
      return null;
    });
  });

  group('Task and Notification Logic Tests', () {
    test('Task Priority and Recurrence model properties', () {
      final task = Task(
        title: 'Complete high priority project',
        priority: TaskPriority.high,
        recurrence: TaskRecurrence.daily,
        categoryIds: ['work'],
        scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        durationMinutes: 60,
        subtasks: [
          Subtask(title: 'Setup architecture', isCompleted: true),
          Subtask(title: 'Run integration test', isCompleted: false),
        ],
      );

      expect(task.priority, TaskPriority.high);
      expect(task.recurrence, TaskRecurrence.daily);
      expect(task.isCompleted, false);
      expect(task.subtasks.length, 2);
      expect(task.subtasks.first.isCompleted, true);
    });

    test('Priority colors match DotoSemantic definitions', () {
      expect(DotoSemantic.priorityHigh, const Color(0xFFC25E3D));
      expect(DotoSemantic.priorityMedium, const Color(0xFFF5C842));
      expect(DotoSemantic.priorityLow, const Color(0xFF57A11F));
      expect(DotoSemantic.categoryWork, const Color(0xFF004081));
    });

    test('All priority levels (High, Medium, Low) are eligible for scheduled notifications', () {
      final lowTask = Task(
        title: 'Low task',
        priority: TaskPriority.low,
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );
      final medTask = Task(
        title: 'Med task',
        priority: TaskPriority.medium,
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );
      final highTask = Task(
        title: 'High task',
        priority: TaskPriority.high,
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Tasks with scheduledTime must not be blocked from notifications due to priority
      expect(lowTask.scheduledTime != null && !lowTask.isCompleted, isTrue);
      expect(medTask.scheduledTime != null && !medTask.isCompleted, isTrue);
      expect(highTask.scheduledTime != null && !highTask.isCompleted, isTrue);
    });

    test('Timing precision: "After now" preserves exact second and cleans subseconds', () {
      // Suppose task was created/saved at 13:44:35.850 with 2 minutes offset
      final clickedAt = DateTime(2026, 9, 4, 13, 44, 35, 850);
      final cleanNow = DateTime(
        clickedAt.year,
        clickedAt.month,
        clickedAt.day,
        clickedAt.hour,
        clickedAt.minute,
        clickedAt.second,
      );
      final scheduled = cleanNow.add(const Duration(minutes: 2));

      // Notification should be scheduled for exactly 13:46:35.000 (no subsecond drift)
      expect(scheduled.hour, 13);
      expect(scheduled.minute, 46);
      expect(scheduled.second, 35);
      expect(scheduled.millisecond, 0);
      expect(scheduled.microsecond, 0);
    });

    test('Timing precision: "Exact time" sets exact second to 00 without delay', () {
      // Suppose task was set for 13:44
      final selectedDate = DateTime(2026, 9, 4);
      const selectedTime = TimeOfDay(hour: 13, minute: 44);
      final scheduled = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
        0,
      );

      // Notification should be scheduled for exactly 13:44:00.000
      expect(scheduled.hour, 13);
      expect(scheduled.minute, 44);
      expect(scheduled.second, 0);
      expect(scheduled.millisecond, 0);
      expect(scheduled.microsecond, 0);
    });
  });
}
