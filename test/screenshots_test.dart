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
import 'package:doto/theme/doto_theme.dart';

class MockTaskProvider extends ChangeNotifier implements TaskProvider {
  String _selectedCategory = 'all';
  String? _expandedTaskId;

  @override
  List<Task> get tasks => [
    Task(
      title: 'Ship the auth refactor',
      description: 'Split session handling out of the gateway',
      priority: TaskPriority.high,
      categoryIds: ['work'],
      scheduledTime: DateTime(2026, 9, 2, 16, 30),
      durationMinutes: 120,
      subtasks: [
        Subtask(title: 'Isolate token parser', isCompleted: true),
        Subtask(title: 'Write session tests', isCompleted: false),
        Subtask(title: 'Deploy gateway proxy', isCompleted: false),
      ],
    ),
    Task(
      title: 'Review the Oslo proposal',
      priority: TaskPriority.medium,
      categoryIds: ['work'],
      scheduledTime: DateTime(2026, 9, 3, 9, 0),
      durationMinutes: 45,
    ),
  ];
  
  @override
  List<TaskCategory> get categories => [
    TaskCategory(id: 'work', name: 'Work', colorHex: 0xFF004081),
    TaskCategory(id: 'personal', name: 'Personal', colorHex: 0xFF00A9DC),
    TaskCategory(id: 'health', name: 'Health', colorHex: 0xFF57A11F),
    TaskCategory(id: 'home', name: 'Home', colorHex: 0xFFF5C842),
  ];
  
  @override
  List<Task> get pendingTasks => tasks;
  
  @override
  List<Task> get completedTasks => [
    Task(
      title: 'Send sprint notes',
      priority: TaskPriority.medium,
      categoryIds: ['work'],
      recurrence: TaskRecurrence.weekly,
      scheduledTime: DateTime(2026, 9, 1, 17, 0),
      durationMinutes: 15,
      isCompleted: true,
    ),
    Task(
      title: 'Water the plants',
      priority: TaskPriority.low,
      categoryIds: ['home'],
      recurrence: TaskRecurrence.weekly,
      scheduledTime: DateTime(2026, 9, 1, 19, 0),
      durationMinutes: 15,
      isCompleted: true,
    ),
  ];

  @override
  String get selectedCategory => _selectedCategory;

  @override
  String? get expandedTaskId => _expandedTaskId;

  @override
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  @override
  void toggleTaskExpansion(String id) {
    _expandedTaskId = _expandedTaskId == id ? null : id;
    notifyListeners();
  }

  @override
  int get pendingCount => pendingTasks.length;

  @override
  int get completedCount => completedTasks.length;

  @override
  int get totalCompletedCount => completedTasks.length;

  @override
  Future<void> init() async {}
  
  @override
  Future<void> addTask(Task task) async {}
  
  @override
  Future<void> updateTask(Task task) async {}
  
  @override
  Future<void> toggleTaskCompletion(Task task) async {}

  @override
  Future<void> toggleSubtask(Task task, Subtask subtask) async {}
  
  @override
  Future<void> deleteTask(String id) async {}
  
  @override
  Future<void> addCategory(TaskCategory category) async {}
  
  @override
  int get currentStreak => 12;

  @override
  int get bestStreak => 21;
  
  @override
  List<DailyStats> get last7DaysStats => [];

  @override
  int get last7DaysClosedCount => 25;

  @override
  Map<String, int> get timeByCategoryMinutes => {
    'work': 180,
    'personal': 30,
    'health': 45,
    'home': 15,
  };

  @override
  double get completionRate => 0.88;
}

Widget createScreen(Widget screen) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<TaskProvider>(create: (_) => MockTaskProvider()),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dotoTheme(dark: false),
      darkTheme: dotoTheme(dark: true),
      home: DotoBackdrop(child: screen),
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
  });

  testWidgets('Screenshot AddTaskScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const AddTaskScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Screenshot SettingsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const SettingsScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Screenshot StatsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const StatsScreen()));
    await tester.pumpAndSettle();
  });
}
