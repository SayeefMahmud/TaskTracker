import 'package:flutter/foundation.dart';
import '../models/task.dart';
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
    
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _db.addTask(task);
    _tasks.add(task);
    
    if (task.scheduledTime != null) {
      await _notifications.scheduleTaskNotification(task);
    }
    
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
    
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    await _notifications.cancelTaskNotification(id);
    notifyListeners();
  }

  Future<void> addCategory(TaskCategory category) async {
    await _db.addCategory(category);
    _categories.add(category);
    notifyListeners();
  }
}
