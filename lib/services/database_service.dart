import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class DatabaseService {
  static const String _tasksBoxName = 'tasksBox';
  static const String _categoriesBoxName = 'categoriesBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(TaskCategoryAdapter());

    await Hive.openBox<Task>(_tasksBoxName);
    await Hive.openBox<TaskCategory>(_categoriesBoxName);
  }

  Box<Task> get tasksBox => Hive.box<Task>(_tasksBoxName);
  Box<TaskCategory> get categoriesBox => Hive.box<TaskCategory>(_categoriesBoxName);

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
}
