import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/user_stats.dart';

class DatabaseService {
  static const String _tasksBoxName = 'tasksBox';
  static const String _categoriesBoxName = 'categoriesBox';
  static const String _statsBoxName = 'statsBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(TaskCategoryAdapter());
    Hive.registerAdapter(TaskRecurrenceAdapter());
    Hive.registerAdapter(SubtaskAdapter());
    Hive.registerAdapter(DailyStatsAdapter());

    await Hive.openBox<Task>(_tasksBoxName);
    await Hive.openBox<TaskCategory>(_categoriesBoxName);
    await Hive.openBox<DailyStats>(_statsBoxName);
  }

  Box<Task> get tasksBox => Hive.box<Task>(_tasksBoxName);
  Box<TaskCategory> get categoriesBox => Hive.box<TaskCategory>(_categoriesBoxName);
  Box<DailyStats> get statsBox => Hive.box<DailyStats>(_statsBoxName);

  List<Task> getTasks() {
    return tasksBox.values.toList();
  }

  Future<void> addTask(Task task) async {
    await tasksBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await task.save();
  }

  Future<void> deleteTask(String id) async {
    await tasksBox.delete(id);
  }

  List<TaskCategory> getCategories() {
    return categoriesBox.values.toList();
  }

  Future<void> addCategory(TaskCategory category) async {
    await categoriesBox.put(category.id, category);
  }
  
  // Stats methods
  DailyStats getDailyStats(String localDate) {
    return statsBox.get(localDate) ?? DailyStats(localDate: localDate);
  }
  
  Future<void> saveDailyStats(DailyStats stats) async {
    await statsBox.put(stats.localDate, stats);
  }
  
  List<DailyStats> getAllStats() {
    return statsBox.values.toList();
  }
}
