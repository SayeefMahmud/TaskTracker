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

    test('High priority color is DotoSemantic.priorityHigh', () {
      expect(DotoSemantic.priorityHigh, const Color(0xFFC25E3D));
      expect(DotoSemantic.categoryWork, const Color(0xFF004081));
    });

    test('Non-high priority tasks vs high priority filtering', () {
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

      expect(lowTask.priority == TaskPriority.high, isFalse);
      expect(medTask.priority == TaskPriority.high, isFalse);
      expect(highTask.priority == TaskPriority.high, isTrue);
    });
  });
}
