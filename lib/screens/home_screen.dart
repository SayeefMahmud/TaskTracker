import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../theme.dart';
import '../utils/duration_formatter.dart';
import 'settings_screen.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoTo.'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _NeoIconButton(
              icon: Icons.settings_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            // Neo tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _NeoTab(
                    label: 'Pending',
                    isActive: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 10),
                  _NeoTab(
                    label: 'Done',
                    isActive: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Task list
            Expanded(
              child: _selectedTab == 0
                  ? const TaskList(isCompleted: false)
                  : const TaskList(isCompleted: true),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: AppThemes.neoBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemes.neoBlack, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF888888),
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 32),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          ),
        ),
      ),
    );
  }
}

// ─── Neo Tab ─────────────────────────────────────────────────

class _NeoTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NeoTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppThemes.neoBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppThemes.neoBlack, width: 2.5),
          boxShadow: isActive
              ? const [BoxShadow(color: AppThemes.neoBlack, offset: Offset(2, 2), blurRadius: 0)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : AppThemes.neoBlack,
          ),
        ),
      ),
    );
  }
}

// ─── Neo Icon Button ─────────────────────────────────────────

class _NeoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NeoIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppThemes.neoWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppThemes.neoBlack, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppThemes.neoBlack, offset: Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: Icon(icon, size: 18, color: AppThemes.neoBlack),
      ),
    );
  }
}

// ─── Task List ───────────────────────────────────────────────

class TaskList extends StatelessWidget {
  final bool isCompleted;
  const TaskList({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = isCompleted ? provider.completedTasks : provider.pendingTasks;

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppThemes.neoYellow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: AppThemes.neoBlack, offset: Offset(4, 4), blurRadius: 0),
                    ],
                  ),
                  child: Text(
                    isCompleted ? '🎉' : '📝',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isCompleted ? 'Nothing completed yet!' : 'No tasks yet!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppThemes.neoBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isCompleted ? 'Complete some tasks to see them here' : 'Tap + to add your first task',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppThemes.neoBlack.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 80, left: 20, right: 20),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return NeoTaskTile(task: task);
          },
        );
      },
    );
  }
}

// ─── Neo Task Tile ───────────────────────────────────────────

class NeoTaskTile extends StatelessWidget {
  final Task task;
  const NeoTaskTile({super.key, required this.task});

  Color _cardColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return AppThemes.neoYellow;
      case TaskPriority.medium:
        return AppThemes.neoBlue;
      case TaskPriority.low:
        return AppThemes.neoMint;
    }
  }

  void _showSubtasksSheet(BuildContext context, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.neoWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppThemes.neoBlack, width: 3),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Subtasks: ${task.title}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: task.subtasks.length,
                      itemBuilder: (context, index) {
                        final sub = task.subtasks[index];
                        return GestureDetector(
                          onTap: () {
                            setStateSheet(() {
                              sub.isCompleted = !sub.isCompleted;
                            });
                            provider.updateTask(task);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: sub.isCompleted ? AppThemes.neoMint : Colors.white,
                              border: Border.all(color: AppThemes.neoBlack, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  sub.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: AppThemes.neoBlack,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    sub.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final completedSubtasks = task.subtasks.where((s) => s.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          if (task.subtasks.isNotEmpty) {
            _showSubtasksSheet(context, provider);
          } else {
            provider.toggleTaskCompletion(task);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor(),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppThemes.neoBlack, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: task.isCompleted
                    ? AppThemes.neoBlack.withValues(alpha: 0.3)
                    : AppThemes.neoBlack,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Square checkbox
              GestureDetector(
                onTap: () => provider.toggleTaskCompletion(task),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: task.isCompleted ? AppThemes.neoBlack : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppThemes.neoBlack,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: AppThemes.neoBlack,
                        decorationThickness: 2.5,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppThemes.neoBlack.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (task.scheduledTime != null)
                          _NeoChip(
                            label: '⏰ ${DateFormat('MMM d, h:mm a').format(task.scheduledTime!)}',
                            bgColor: Colors.white,
                            bold: false,
                          ),
                        if (task.durationMinutes != null && task.durationMinutes! > 0)
                          Semantics(
                            label: 'Duration: ${formatDuration(task.durationMinutes)}',
                            child: Tooltip(
                              message: 'Estimated duration',
                              child: _NeoChip(
                                label: '⏳ ${formatDuration(task.durationMinutes)}',
                                bgColor: Colors.white,
                                bold: false,
                              ),
                            ),
                          ),
                        _NeoChip(
                          label: task.priority.name.toUpperCase(),
                          bgColor: task.priority == TaskPriority.high
                              ? AppThemes.neoRed
                              : Colors.white,
                          textColor: task.priority == TaskPriority.high
                              ? Colors.white
                              : AppThemes.neoBlack,
                          bold: true,
                        ),
                        if (task.subtasks.isNotEmpty)
                          _NeoChip(
                            label: '$completedSubtasks/${task.subtasks.length} Sub',
                            bgColor: Colors.white,
                            bold: true,
                          ),
                        if (task.recurrence != TaskRecurrence.none)
                          _NeoChip(
                            label: '🔁 ${task.recurrence.name.toUpperCase()}',
                            bgColor: Colors.white,
                            bold: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete button
              GestureDetector(
                onTap: () => provider.deleteTask(task.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppThemes.neoBlack, width: 2),
                  ),
                  child: const Icon(Icons.close_rounded, size: 16, color: AppThemes.neoBlack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Neo Chip ────────────────────────────────────────────────

class _NeoChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool bold;

  const _NeoChip({
    required this.label,
    required this.bgColor,
    this.textColor = AppThemes.neoBlack,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppThemes.neoBlack, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          color: textColor,
          letterSpacing: bold ? 0.5 : 0,
        ),
      ),
    );
  }
}
