import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_task_screen.dart';
import '../theme/doto_theme.dart';
import '../utils/duration_formatter.dart';
import 'doto_checkbox.dart';
import 'priority_chip.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  bool _isDeletePressed = false;

  void _openEditTask(BuildContext context) {
    if (!widget.task.isCompleted) {
      HapticFeedback.selectionClick();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddTaskScreen(taskToEdit: widget.task),
        ),
      );
    }
  }

  Color _getCategoryColor(String? catName) {
    switch (catName?.toLowerCase()) {
      case 'personal':
        return DotoSemantic.categoryPersonal;
      case 'health':
        return DotoSemantic.categoryHealth;
      case 'home':
        return DotoSemantic.categoryHome;
      case 'work':
      default:
        return DotoSemantic.categoryWork;
    }
  }

  String _formatRepeat(TaskRecurrence r) {
    switch (r) {
      case TaskRecurrence.daily:
        return 'Daily';
      case TaskRecurrence.weekly:
        return 'Weekly';
      case TaskRecurrence.monthly:
        return 'Monthly';
      case TaskRecurrence.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;
    final provider = Provider.of<TaskProvider>(context);
    final task = widget.task;

    final isExpanded = provider.expandedTaskId == task.id;
    final totalSubtasks = task.subtasks.length;
    final completedSubtasks = task.subtasks.where((s) => s.isCompleted).length;
    final isAllSubtasksDone = totalSubtasks > 0 && completedSubtasks == totalSubtasks;
    final progressFraction = totalSubtasks > 0 ? (completedSubtasks / totalSubtasks) : 0.0;

    final primaryCategory = task.categoryIds.isNotEmpty ? task.categoryIds.first : 'Work';
    final categoryColor = _getCategoryColor(primaryCategory);

    return RepaintBoundary(
      child: GlassSurface(
        radius: DotoRadius.card,
        padding: const EdgeInsets.all(DotoSpace.cardPadding),
        shadow: DotoShadow.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox on left
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: DotoCheckbox(
                value: task.isCompleted,
                onChanged: (val) {
                  provider.toggleTaskCompletion(task);
                },
              ),
            ),
            const SizedBox(width: 12),

            // Main task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clickable Header & Title & Description (triggers Edit Task if pending)
                  GestureDetector(
                    onTap: () => _openEditTask(context),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meta Line (Category + Repeat Cadence)
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              primaryCategory.toUpperCase(),
                              style: DotoText.categoryLabel.copyWith(
                                color: c.muted,
                              ),
                            ),
                            if (task.recurrence != TaskRecurrence.none) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.repeat_rounded,
                                size: 12,
                                color: c.muted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatRepeat(task.recurrence),
                                style: DotoText.categoryLabel.copyWith(
                                  color: c.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          task.title,
                          style: DotoText.cardTitle.copyWith(
                            color: task.isCompleted ? c.fg.withValues(alpha: 0.5) : c.fg,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: c.fg.withValues(alpha: 0.5),
                          ),
                        ),

                        // Optional description
                        if (task.description != null && task.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: DotoText.body.copyWith(
                              color: c.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Subtask progress row
                  if (totalSubtasks > 0) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        provider.toggleTaskExpansion(task.id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          // 5px progress bar
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: c.field,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedFractionallySizedBox(
                                  duration: DotoMotion.progress,
                                  curve: DotoMotion.curve,
                                  widthFactor: progressFraction,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isAllSubtasksDone ? DotoSemantic.success : c.accent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Subtask counter
                          Text(
                            '$completedSubtasks/$totalSubtasks',
                            style: DotoText.counter.copyWith(
                              color: c.muted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Animated rotating chevron
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            curve: DotoMotion.curve,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: c.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expandable checklist
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Column(
                          children: List.generate(task.subtasks.length, (index) {
                            final sub = task.subtasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  DotoSubtaskCheckbox(
                                    value: sub.isCompleted,
                                    onChanged: (val) {
                                      provider.toggleSubtask(task, sub);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.toggleSubtask(task, sub);
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Text(
                                        sub.title,
                                        style: DotoText.body.copyWith(
                                          fontSize: 13.5,
                                          color: sub.isCompleted ? c.fg.withValues(alpha: 0.5) : c.fg,
                                          decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                          decorationColor: c.fg.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],

                  // Chips row (also triggers Edit Task if pending)
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _openEditTask(context),
                    behavior: HitTestBehavior.opaque,
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Due chip
                        if (task.scheduledTime != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.field,
                              borderRadius: BorderRadius.circular(DotoRadius.pill),
                              border: Border.all(color: c.edge, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded, size: 12, color: c.muted),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('EEE d MMM · HH:mm').format(task.scheduledTime!),
                                  style: DotoText.metaChip.copyWith(color: c.fg),
                                ),
                              ],
                            ),
                          ),

                        // Duration chip
                        if (task.durationMinutes != null && task.durationMinutes! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.field,
                              borderRadius: BorderRadius.circular(DotoRadius.pill),
                              border: Border.all(color: c.edge, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.equalizer_rounded, size: 12, color: c.muted),
                                const SizedBox(width: 5),
                                Text(
                                  formatDuration(task.durationMinutes) ?? '',
                                  style: DotoText.metaChip.copyWith(color: c.fg),
                                ),
                              ],
                            ),
                          ),

                        // Priority chip
                        PriorityChipWidget(
                          priority: task.priority,
                          isSelected: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Delete button on top right
            GestureDetector(
              onTapDown: (_) => setState(() => _isDeletePressed = true),
              onTapUp: (_) => setState(() => _isDeletePressed = false),
              onTapCancel: () => setState(() => _isDeletePressed = false),
              onTap: () {
                HapticFeedback.mediumImpact();
                provider.deleteTask(task.id);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isDeletePressed ? DotoSemantic.destructive.withValues(alpha: 0.14) : Colors.transparent,
                ),
                child: Center(
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: _isDeletePressed ? DotoSemantic.destructive : c.muted.withValues(alpha: 0.40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
