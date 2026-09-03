import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/user_stats.dart';

class DatabaseService {
  static const String _tasksBoxName = 'tasksBox';
  static const String _categoriesBoxName = 'categoriesBox';
  static const String _statsBoxName = 'statsBox';
  static bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskPriorityAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TaskCategoryAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TaskRecurrenceAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SubtaskAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(DailyStatsAdapter());

    if (!Hive.isBoxOpen(_tasksBoxName)) await Hive.openBox<Task>(_tasksBoxName);
    if (!Hive.isBoxOpen(_categoriesBoxName)) await Hive.openBox<TaskCategory>(_categoriesBoxName);
    if (!Hive.isBoxOpen(_statsBoxName)) await Hive.openBox<DailyStats>(_statsBoxName);
    _initialized = true;
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

  Future<Task?> markTaskCompletedById(String id) async {
    if (!_initialized || !Hive.isBoxOpen(_tasksBoxName)) {
      await init();
    }
    final task = tasksBox.get(id);
    if (task != null && !task.isCompleted) {
      task.isCompleted = true;
      task.completedAt = DateTime.now();
      for (var sub in task.subtasks) {
        sub.isCompleted = true;
      }

      final now = DateTime.now();
      final key = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final stats = getDailyStats(key);
      stats.completedCount += 1;
      await saveDailyStats(stats);

      Task? nextTask;
      if (task.recurrence != TaskRecurrence.none && task.nextRecurrenceId == null) {
        DateTime? nextScheduled = task.scheduledTime ?? DateTime.now();
        switch (task.recurrence) {
          case TaskRecurrence.daily:
            nextScheduled = nextScheduled.add(const Duration(days: 1));
            break;
          case TaskRecurrence.weekly:
            nextScheduled = nextScheduled.add(const Duration(days: 7));
            break;
          case TaskRecurrence.monthly:
            int nextMonth = nextScheduled.month + 1;
            int nextYear = nextScheduled.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
            int nextDay = nextScheduled.day > daysInNextMonth ? daysInNextMonth : nextScheduled.day;
            nextScheduled = DateTime(nextYear, nextMonth, nextDay, nextScheduled.hour, nextScheduled.minute);
            break;
          default:
            break;
        }

        nextTask = Task(
          title: task.title,
          description: task.description,
          scheduledTime: nextScheduled,
          priority: task.priority,
          categoryIds: List.from(task.categoryIds),
          recurrence: task.recurrence,
          subtasks: task.subtasks.map((s) => Subtask(title: s.title, isCompleted: false)).toList(),
          durationMinutes: task.durationMinutes,
        );

        task.nextRecurrenceId = nextTask.id;
        await addTask(nextTask);
      }

      await task.save();
      return nextTask;
    }
    return null;
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
