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

  testGoldens('Screenshot HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(createScreen(const HomeScreen()), surfaceSize: const Size(393, 852));
    await screenMatchesGolden(tester, 'home_screen');
  });

  testGoldens('Screenshot AddTaskScreen', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(createScreen(const AddTaskScreen()), surfaceSize: const Size(393, 852));
    await screenMatchesGolden(tester, 'add_task_screen');
  });

  testGoldens('Screenshot EditTaskScreen', (WidgetTester tester) async {
    final task = Task(
      id: 'task-edit-demo',
      title: 'Ship the auth refactor',
      description: 'Split session handling out of the gateway',
      priority: TaskPriority.high,
      categoryIds: ['work'],
      scheduledTime: DateTime(2026, 9, 3, 14, 30),
      subtasks: [
        Subtask(title: 'Isolate token parser', isCompleted: true),
        Subtask(title: 'Write session tests', isCompleted: false),
        Subtask(title: 'Deploy gateway proxy', isCompleted: false),
      ],
    );
    await tester.pumpWidgetBuilder(createScreen(AddTaskScreen(taskToEdit: task)), surfaceSize: const Size(393, 852));
    await screenMatchesGolden(tester, 'edit_task_screen');
  });

  testGoldens('Screenshot SettingsScreen', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(createScreen(const SettingsScreen()), surfaceSize: const Size(393, 852));
    await screenMatchesGolden(tester, 'settings_screen');
  });

  testGoldens('Screenshot StatsScreen', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(createScreen(const StatsScreen()), surfaceSize: const Size(393, 852));
    await screenMatchesGolden(tester, 'stats_screen');
  });

  testGoldens('Screenshot AddTaskScreen ExactTime', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(createScreen(const AddTaskScreen()), surfaceSize: const Size(393, 852));
    await tester.tap(find.text('Exact time'));
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'add_task_exact_time');
  });

  testGoldens('Screenshot NotificationShade', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(const NotificationShadePreview(), surfaceSize: const Size(393, 852));
    await screenMatchesGolden(tester, 'notification_shade');
  });
}

class NotificationShadePreview extends StatelessWidget {
  const NotificationShadePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0B1120),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Android status bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('14:30', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    Row(
                      children: const [
                        Icon(Icons.wifi, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Icon(Icons.battery_full, color: Colors.white, size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Section Header
                Row(
                  children: const [
                    Text('NOTIFICATIONS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    Spacer(),
                    Text('Clear all', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                // Persistent Sticky Notification Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFC25E3D).withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFC25E3D).withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Header Line
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFC25E3D),
                            ),
                            child: const Icon(Icons.check, size: 15, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Text('DoTo', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          const Text('• now', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC25E3D).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFC25E3D), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.push_pin, size: 10, color: Color(0xFFC25E3D)),
                                SizedBox(width: 4),
                                Text('STICKY · HIGH PRIORITY', style: TextStyle(color: Color(0xFFC25E3D), fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Title & Description
                      const Text(
                        'Ship the auth refactor',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Split session handling out of the gateway · Due Today 14:30',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      // Action buttons in notification shade
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF57A11F).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF57A11F), width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF57A11F)),
                                SizedBox(width: 8),
                                Text('Mark Completed', style: TextStyle(color: Color(0xFF57A11F), fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Open App', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
