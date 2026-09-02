import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:doto/screens/home_screen.dart';
import 'package:doto/screens/add_task_screen.dart';
import 'package:doto/screens/settings_screen.dart';
import 'package:doto/screens/stats_screen.dart';
import 'package:doto/providers/task_provider.dart';
import 'package:doto/providers/theme_provider.dart';
import 'package:doto/models/task.dart';
import 'package:doto/models/user_stats.dart';

class MockTaskProvider extends ChangeNotifier implements TaskProvider {
  @override
  List<Task> get tasks => [];
  
  @override
  List<TaskCategory> get categories => [
    TaskCategory(id: '1', name: 'Work', colorHex: 0xFF2196F3),
    TaskCategory(id: '2', name: 'Personal', colorHex: 0xFF4CAF50),
  ];
  
  @override
  List<Task> get pendingTasks => [
    Task(title: 'Buy groceries', priority: TaskPriority.high, categoryIds: ['1']),
    Task(title: 'Call mom', priority: TaskPriority.medium, categoryIds: ['2']),
  ];
  
  @override
  List<Task> get completedTasks => [
    Task(title: 'Read a book', priority: TaskPriority.low, categoryIds: ['2'])..isCompleted = true,
  ];

  @override
  Future<void> init() async {}
  
  @override
  Future<void> addTask(Task task) async {}
  
  @override
  Future<void> updateTask(Task task) async {}
  
  @override
  Future<void> toggleTaskCompletion(Task task) async {}
  
  @override
  Future<void> deleteTask(String id) async {}
  
  @override
  Future<void> addCategory(TaskCategory category) async {}
  
  @override
  int get currentStreak => 5;
  
  @override
  List<DailyStats> get last7DaysStats => [];
}

Widget createScreen(Widget screen) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<TaskProvider>(create: (_) => MockTaskProvider()),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: screen,
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testWidgets('Screenshot HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const HomeScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(HomeScreen), matchesGoldenFile('home_screen.png'));
  });

  testWidgets('Screenshot AddTaskScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const AddTaskScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(AddTaskScreen), matchesGoldenFile('add_task_screen.png'));
  });

  testWidgets('Screenshot SettingsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const SettingsScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SettingsScreen), matchesGoldenFile('settings_screen.png'));
  });

  testWidgets('Screenshot StatsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const StatsScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(StatsScreen), matchesGoldenFile('stats_screen.png'));
  });
}
