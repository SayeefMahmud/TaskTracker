import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/user_stats.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notifications = NotificationService();

  List<Task> _tasks = [];
  List<TaskCategory> _categories = [];
  
  List<Task> get tasks => _tasks;
  List<TaskCategory> get categories => _categories;
  
  List<Task> get pendingTasks {
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    pending.sort((a, b) => (a.scheduledTime ?? DateTime(2100)).compareTo(b.scheduledTime ?? DateTime(2100)));
    return pending;
  }
  
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  Future<void> init() async {
    await _db.init();
    await _notifications.init();
    
    _tasks = _db.getTasks();
    _categories = _db.getCategories();
    
    if (_categories.isEmpty) {
      await addCategory(TaskCategory(id: '1', name: 'Work', colorHex: 0xFF2196F3));
      await addCategory(TaskCategory(id: '2', name: 'Personal', colorHex: 0xFF4CAF50));
      await addCategory(TaskCategory(id: '3', name: 'Shopping', colorHex: 0xFFFF9800));
    }
    
    _updateWidget();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _db.addTask(task);
    _tasks.add(task);
    
    if (task.scheduledTime != null) {
      await _notifications.scheduleTaskNotification(task);
    }
    
    _updateWidget();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
    
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    
    await _notifications.cancelTaskNotification(task.id);
    if (task.scheduledTime != null && !task.isCompleted) {
      await _notifications.scheduleTaskNotification(task);
    }
    
    _updateWidget();
    notifyListeners();
  }

  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _incrementStats() async {
    final key = _getTodayKey();
    final stats = _db.getDailyStats(key);
    stats.completedCount += 1;
    await _db.saveDailyStats(stats);
  }

  Future<void> _decrementStats() async {
    final key = _getTodayKey();
    final stats = _db.getDailyStats(key);
    if (stats.completedCount > 0) {
      stats.completedCount -= 1;
      await _db.saveDailyStats(stats);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    if (!task.isCompleted) {
      // Mark as completed
      task.isCompleted = true;
      task.completedAt = DateTime.now();
      
      // Auto-complete subtasks
      for (var sub in task.subtasks) {
        sub.isCompleted = true;
      }
      
      await _incrementStats();

      // Recurrence logic
      if (task.recurrence != TaskRecurrence.none && task.nextRecurrenceId == null) {
        DateTime? nextScheduled = task.scheduledTime;
        if (nextScheduled != null) {
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
        }
        
        final clone = Task(
          title: task.title,
          description: task.description,
          scheduledTime: nextScheduled,
          priority: task.priority,
          categoryIds: List.from(task.categoryIds),
          recurrence: task.recurrence,
          subtasks: task.subtasks.map((s) => Subtask(title: s.title, isCompleted: false)).toList(),
        );
        
        task.nextRecurrenceId = clone.id;
        await _db.addTask(clone);
        _tasks.add(clone);
        if (clone.scheduledTime != null) {
          await _notifications.scheduleTaskNotification(clone);
        }
      }
    } else {
      // Undo completion
      task.isCompleted = false;
      task.completedAt = null;
      for (var sub in task.subtasks) {
        sub.isCompleted = false;
      }
      await _decrementStats();
      
      if (task.nextRecurrenceId != null) {
         await deleteTask(task.nextRecurrenceId!);
         task.nextRecurrenceId = null;
      }
    }
    
    await updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    await _notifications.cancelTaskNotification(id);
    
    _updateWidget();
    notifyListeners();
  }

  Future<void> addCategory(TaskCategory category) async {
    await _db.addCategory(category);
    _categories.add(category);
    notifyListeners();
  }
  
  // Analytics
  int get currentStreak {
    int streak = 0;
    DateTime date = DateTime.now();
    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(date);
      final stats = _db.getDailyStats(key);
      if (stats.completedCount > 0) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        if (streak == 0 && key == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          date = date.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }
  
  List<DailyStats> get last7DaysStats {
    List<DailyStats> list = [];
    DateTime date = DateTime.now().subtract(const Duration(days: 6));
    for (int i = 0; i < 7; i++) {
      final key = DateFormat('yyyy-MM-dd').format(date);
      list.add(_db.getDailyStats(key));
      date = date.add(const Duration(days: 1));
    }
    return list;
  }

  Future<void> _updateWidget() async {
    if (!kIsWeb) {
      try {
        final topTasks = pendingTasks.take(3).map((t) => {
          'title': t.title,
          'priority': t.priority.index
        }).toList();
        
        await HomeWidget.saveWidgetData<String>('pending_tasks', jsonEncode(topTasks));
        await HomeWidget.updateWidget(name: 'DoToWidgetProvider', iOSName: 'DoToWidget');
      } catch (e) {
        debugPrint('Failed to update widget: $e');
      }
    }
  }
}
