import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 2)
class TaskCategory {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int colorHex;

  TaskCategory({required this.id, required this.name, required this.colorHex});
}

@HiveType(typeId: 3)
enum TaskRecurrence {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
}

@HiveType(typeId: 4)
class Subtask {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool isCompleted;

  Subtask({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? scheduledTime;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  TaskPriority priority;

  @HiveField(6)
  List<String> categoryIds;

  @HiveField(7)
  int? notificationId;

  @HiveField(8, defaultValue: TaskRecurrence.none)
  TaskRecurrence recurrence;

  @HiveField(9)
  DateTime? completedAt;

  @HiveField(10, defaultValue: [])
  List<Subtask> subtasks;
  
  @HiveField(11)
  String? nextRecurrenceId;

  @HiveField(12)
  int? durationMinutes;

  Task({
    String? id,
    required this.title,
    this.description,
    this.scheduledTime,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.categoryIds = const [],
    this.notificationId,
    this.recurrence = TaskRecurrence.none,
    this.completedAt,
    this.subtasks = const [],
    this.nextRecurrenceId,
    this.durationMinutes,
  }) : id = id ?? const Uuid().v4();
}

