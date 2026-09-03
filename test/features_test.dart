import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:doto/models/task.dart';
import 'package:doto/providers/task_provider.dart';
import 'package:doto/screens/add_task_screen.dart';
import 'package:doto/widgets/task_card.dart';
import 'package:doto/theme/doto_theme.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'initialize') return true;
      return null;
    });
  });

  group('Edit Task and Timing Options Widget Tests', () {
    testWidgets('AddTaskScreen renders in Create mode with 2 timing options and NO duration', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: dotoTheme(dark: false),
          home: const AddTaskScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header should say "Add task"
      expect(find.text('Add task'), findsOneWidget);

      // Duration section should NOT exist
      expect(find.text('DURATION'), findsNothing);

      // Timing section should exist with two options
      expect(find.text('TIMING'), findsOneWidget);
      expect(find.text('After now'), findsOneWidget);
      expect(find.text('Exact time'), findsOneWidget);

      // By default, "After now" (relative) is selected
      expect(find.text('DAYS'), findsOneWidget);
      expect(find.text('HOURS'), findsOneWidget);
      expect(find.text('MINUTES'), findsOneWidget);
      expect(find.text('+15m'), findsOneWidget);
      expect(find.text('+30m'), findsOneWidget);
      expect(find.text('+1h'), findsOneWidget);

      // Switch to Exact time
      await tester.tap(find.text('Exact time'));
      await tester.pumpAndSettle();

      // Days/Hours/Minutes should now be gone, date/time pickers shown
      expect(find.text('DAYS'), findsNothing);
      expect(find.byIcon(Icons.calendar_today_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('Relative quick presets update timing controllers', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: dotoTheme(dark: false),
          home: const AddTaskScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "+2h"
      await tester.tap(find.text('+2h'));
      await tester.pumpAndSettle();

      // Hours should now show 2, minutes 0, days 0
      final hoursField = tester.widget<TextField>(
        find.ancestor(
          of: find.text('2'),
          matching: find.byType(TextField),
        ),
      );
      expect(hoursField.controller?.text, '2');

      // Tap "+1d"
      await tester.tap(find.text('+1d'));
      await tester.pumpAndSettle();

      final daysField = tester.widget<TextField>(
        find.ancestor(
          of: find.text('1'),
          matching: find.byType(TextField),
        ),
      );
      expect(daysField.controller?.text, '1');
    });

    testWidgets('AddTaskScreen pre-populates fields and subtasks when taskToEdit is provided', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final existingTask = Task(
        id: 'task-123',
        title: 'Review PR & Deploy',
        description: 'Check CI pipeline and merge',
        priority: TaskPriority.high,
        categoryIds: ['work'],
        recurrence: TaskRecurrence.daily,
        scheduledTime: DateTime.now().add(const Duration(hours: 4)),
        subtasks: [
          Subtask(id: 'sub-1', title: 'Verify test suite', isCompleted: true),
          Subtask(id: 'sub-2', title: 'Deploy to prod', isCompleted: false),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: dotoTheme(dark: false),
          home: AddTaskScreen(taskToEdit: existingTask),
        ),
      );
      await tester.pumpAndSettle();

      // Title should say "Edit task"
      expect(find.text('Edit task'), findsOneWidget);

      // Button should say "Save changes"
      expect(find.text('Save changes'), findsOneWidget);

      // Form fields should match existingTask
      expect(find.text('Review PR & Deploy'), findsAtLeastNWidgets(1));
      expect(find.text('Check CI pipeline and merge'), findsAtLeastNWidgets(1));

      // Subtasks should be preserved with completion status
      expect(find.text('Verify test suite'), findsOneWidget);
      expect(find.text('Deploy to prod'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget); // Live preview counter
    });

    testWidgets('Tapping on a pending task card opens AddTaskScreen in edit mode', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final task = Task(
        id: 'task-abc',
        title: 'Draft Project Specs',
        priority: TaskPriority.medium,
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
          child: MaterialApp(
            theme: dotoTheme(dark: false),
            home: Scaffold(
              body: TaskCard(task: task),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the task title
      await tester.tap(find.text('Draft Project Specs'));
      await tester.pumpAndSettle();

      // Navigation should have pushed AddTaskScreen in Edit mode
      expect(find.text('Edit task'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('Tapping on a completed task card does NOT open edit screen', (tester) async {
      final completedTask = Task(
        id: 'task-done',
        title: 'Completed Architecture Review',
        priority: TaskPriority.low,
        isCompleted: true,
        scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
          child: MaterialApp(
            theme: dotoTheme(dark: false),
            home: Scaffold(
              body: TaskCard(task: completedTask),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the completed task title
      await tester.tap(find.text('Completed Architecture Review'));
      await tester.pumpAndSettle();

      // Navigation should NOT have opened AddTaskScreen
      expect(find.text('Edit task'), findsNothing);
    });

    testWidgets('AndroidManifest.xml declares ActionBroadcastReceiver', (tester) async {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);
      final content = manifestFile.readAsStringSync();
      expect(
        content.contains('com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver'),
        isTrue,
        reason: 'ActionBroadcastReceiver is required for notification action buttons to be delivered by Android OS',
      );
    });

    testWidgets('Notification service uses sticky channel v2 with additionalFlags', (tester) async {
      final serviceFile = File('lib/services/notification_service.dart');
      expect(serviceFile.existsSync(), isTrue);
      final content = serviceFile.readAsStringSync();
      expect(content.contains('doto_high_priority_sticky_v2'), isTrue);
      expect(content.contains('ongoing: true'), isTrue);
      expect(content.contains('autoCancel: false'), isTrue);
      expect(content.contains('additionalFlags: Int32List.fromList([32, 2])'), isTrue);
      expect(content.contains('doto_notification_action_port'), isTrue);
    });
  });
}
