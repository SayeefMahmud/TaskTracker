import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/doto_theme.dart';
import '../utils/duration_formatter.dart';
import '../widgets/priority_chip.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subtaskInputController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int? _selectedDuration = 30; // default 30m
  TaskPriority _priority = TaskPriority.medium;
  TaskRecurrence _recurrence = TaskRecurrence.none;
  String _selectedCategory = 'work';
  final List<String> _subtasks = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _subtasks.add(text);
        _subtaskInputController.clear();
      });
    }
  }

  void _removeSubtask(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
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
    final isTitleValid = _titleController.text.trim().isNotEmpty;

    final categories = [
      ('Work', DotoSemantic.categoryWork, 'work'),
      ('Personal', DotoSemantic.categoryPersonal, 'personal'),
      ('Health', DotoSemantic.categoryHealth, 'health'),
      ('Home', DotoSemantic.categoryHome, 'home'),
    ];

    final durations = [
      (15, '15m'),
      (30, '30m'),
      (45, '45m'),
      (60, '1h'),
      (120, '2h'),
    ];

    final recurrences = [
      (TaskRecurrence.none, 'None'),
      (TaskRecurrence.daily, 'Daily'),
      (TaskRecurrence.weekly, 'Weekly'),
      (TaskRecurrence.monthly, 'Monthly'),
    ];

    final priorities = [
      TaskPriority.high,
      TaskPriority.medium,
      TaskPriority.low,
    ];

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DotoBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DotoSpace.screenH,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.glass,
                          border: Border.all(color: c.edge, width: 1),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: c.fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Add task',
                      style: DotoText.addTitle.copyWith(
                        color: c.fg,
                      ),
                    ),
                  ],
                ),
              ),

              // Form scroll body
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: DotoSpace.screenH,
                    right: DotoSpace.screenH,
                    bottom: DotoSpace.scrollBottomAdd,
                  ),
                  children: [
                    // LIVE PREVIEW SHEET
                    GlassSurface(
                      radius: DotoRadius.sheet,
                      sigma: 11,
                      padding: const EdgeInsets.all(DotoSpace.panelPadding),
                      shadow: DotoShadow.sheet,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE PREVIEW',
                            style: DotoText.eyebrow.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: c.muted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Inert unchecked circle
                              Container(
                                width: 26,
                                height: 26,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: c.edge,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Meta line
                                    Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _getCategoryColor(_selectedCategory),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _selectedCategory.toUpperCase(),
                                          style: DotoText.categoryLabel.copyWith(
                                            color: c.muted,
                                          ),
                                        ),
                                        if (_recurrence != TaskRecurrence.none) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.repeat_rounded,
                                            size: 12,
                                            color: c.muted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatRepeat(_recurrence),
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
                                      _titleController.text.trim().isEmpty
                                          ? 'Your task title'
                                          : _titleController.text.trim(),
                                      style: DotoText.cardTitle.copyWith(
                                        color: _titleController.text.trim().isEmpty
                                            ? c.fg.withValues(alpha: 0.45)
                                            : c.fg,
                                      ),
                                    ),

                                    // Description
                                    if (_descController.text.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _descController.text.trim(),
                                        style: DotoText.body.copyWith(
                                          color: c.muted,
                                        ),
                                      ),
                                    ],

                                    // Subtasks progress bar
                                    if (_subtasks.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: c.field,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '0/${_subtasks.length}',
                                            style: DotoText.counter.copyWith(
                                              color: c.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    // Chips row
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 7,
                                      runSpacing: 6,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        // Due chip
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
                                                DateFormat('EEE d MMM · HH:mm').format(scheduledDateTime),
                                                style: DotoText.metaChip.copyWith(color: c.fg),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Duration chip
                                        if (_selectedDuration != null && _selectedDuration! > 0)
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
                                                  formatDuration(_selectedDuration) ?? '',
                                                  style: DotoText.metaChip.copyWith(color: c.fg),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Priority chip
                                        PriorityChipWidget(
                                          priority: _priority,
                                          isSelected: false,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // TITLE *
                    Text(
                      'TITLE *',
                      style: DotoText.fieldLabel.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: c.field,
                        borderRadius: BorderRadius.circular(DotoRadius.input),
                        border: Border.all(color: c.edge, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _titleController,
                        style: DotoText.cardTitle.copyWith(color: c.fg),
                        decoration: InputDecoration(
                          hintText: 'What needs doing?',
                          hintStyle: DotoText.cardTitle.copyWith(color: c.muted.withValues(alpha: 0.5)),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // DESCRIPTION
                    Text(
                      'DESCRIPTION',
                      style: DotoText.fieldLabel.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: c.field,
                        borderRadius: BorderRadius.circular(DotoRadius.input),
                        border: Border.all(color: c.edge, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _descController,
                        maxLines: 2,
                        style: DotoText.body.copyWith(color: c.fg),
                        decoration: InputDecoration(
                          hintText: 'Optional detail...',
                          hintStyle: DotoText.body.copyWith(color: c.muted.withValues(alpha: 0.5)),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // CATEGORY
                    Text(
                      'CATEGORY',
                      style: DotoText.fieldLabel.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final (name, dotColor, id) = cat;
                        final isSelected = _selectedCategory == id;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = id);
                          },
                          child: AnimatedContainer(
                            duration: DotoMotion.control,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? c.accent : c.field,
                              borderRadius: BorderRadius.circular(DotoRadius.pill),
                              border: Border.all(
                                color: isSelected ? c.accent : c.edge,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? c.onAccent : dotColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  name,
                                  style: DotoText.navLabel.copyWith(
                                    color: isSelected ? c.onAccent : c.fg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // DUE (Date + Time)
                    Text(
                      'DUE',
                      style: DotoText.fieldLabel.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: c.field,
                                borderRadius: BorderRadius.circular(DotoRadius.input),
                                border: Border.all(color: c.edge, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd.MM.yyyy').format(_selectedDate),
                                    style: DotoText.metaChip.copyWith(fontSize: 13, color: c.fg),
                                  ),
                                  Icon(Icons.calendar_today_outlined, size: 16, color: c.muted),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Time picker
                        SizedBox(
                          width: 116,
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (picked != null) {
                                setState(() => _selectedTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                color: c.field,
                                borderRadius: BorderRadius.circular(DotoRadius.input),
                                border: Border.all(color: c.edge, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: DotoText.metaChip.copyWith(fontSize: 12.5, color: c.fg),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.access_time_rounded, size: 16, color: c.muted),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // DURATION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DURATION',
                          style: DotoText.fieldLabel.copyWith(color: c.muted),
                        ),
                        if (_selectedDuration != null)
                          Text(
                            formatDuration(_selectedDuration) ?? '',
                            style: DotoText.metaChip.copyWith(color: c.muted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: durations.map((d) {
                          final (mins, label) = d;
                          final isSelected = _selectedDuration == mins;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedDuration = isSelected ? null : mins);
                              },
                              child: AnimatedContainer(
                                duration: DotoMotion.control,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? c.accent : c.field,
                                  borderRadius: BorderRadius.circular(DotoRadius.pill),
                                  border: Border.all(
                                    color: isSelected ? c.accent : c.edge,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: DotoText.metaChip.copyWith(
                                    fontSize: 12,
                                    color: isSelected ? c.onAccent : c.fg,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // REPEAT
                    Text(
                      'REPEAT',
                      style: DotoText.fieldLabel.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recurrences.map((r) {
                        final (cadence, label) = r;
                        final isSelected = _recurrence == cadence;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _recurrence = cadence);
                          },
                          child: AnimatedContainer(
                            duration: DotoMotion.control,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? c.accent : c.field,
                              borderRadius: BorderRadius.circular(DotoRadius.pill),
                              border: Border.all(
                                color: isSelected ? c.accent : c.edge,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              label,
                              style: DotoText.navLabel.copyWith(
                                color: isSelected ? c.onAccent : c.fg,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // SUBTASKS
                    Text(
                      'SUBTASKS',
                      style: DotoText.fieldLabel.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_subtasks.length, (idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: c.field,
                            borderRadius: BorderRadius.circular(DotoRadius.row),
                            border: Border.all(color: c.edge, width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 17,
                                height: 17,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: c.edge, width: 1.5),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _subtasks[idx],
                                  style: DotoText.body.copyWith(color: c.fg),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _removeSubtask(idx),
                                child: Icon(Icons.close_rounded, size: 16, color: c.muted),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // Input to add subtask
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.field,
                              borderRadius: BorderRadius.circular(DotoRadius.input),
                              border: Border.all(color: c.edge, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            child: TextField(
                              controller: _subtaskInputController,
                              style: DotoText.body.copyWith(color: c.fg),
                              decoration: InputDecoration(
                                hintText: 'Add a subtask...',
                                hintStyle: DotoText.body.copyWith(color: c.muted.withValues(alpha: 0.5)),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _addSubtask(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addSubtask,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: c.field,
                              borderRadius: BorderRadius.circular(DotoRadius.row),
                              border: Border.all(color: c.edge, width: 1),
                            ),
                            child: Icon(Icons.add_rounded, color: c.fg),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // PRIORITY
                    Text(
                      'PRIORITY',
                      style: DotoText.fieldLabel.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: priorities.map((p) {
                        final isSelected = _priority == p;
                        return PriorityChipWidget(
                          priority: p,
                          isSelected: isSelected,
                          onTap: () => setState(() => _priority = p),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // SAVE TASK BUTTON
                    GestureDetector(
                      onTap: () {
                        if (!isTitleValid) return;
                        HapticFeedback.mediumImpact();

                        final newTask = Task(
                          title: _titleController.text.trim(),
                          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                          scheduledTime: scheduledDateTime,
                          priority: _priority,
                          categoryIds: [_selectedCategory],
                          recurrence: _recurrence,
                          durationMinutes: _selectedDuration,
                          subtasks: _subtasks.map((t) => Subtask(title: t)).toList(),
                        );

                        final provider = Provider.of<TaskProvider>(context, listen: false);
                        provider.addTask(newTask);
                        provider.setSelectedCategory('all'); // Reset filter
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: DotoMotion.control,
                        curve: DotoMotion.curve,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isTitleValid ? c.accent : c.field.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(DotoRadius.pill),
                          border: Border.all(color: c.edge, width: 1),
                          boxShadow: isTitleValid ? DotoShadow.save : null,
                        ),
                        child: Center(
                          child: Text(
                            'Save task',
                            style: DotoText.tabLabel.copyWith(
                              fontSize: 16,
                              color: isTitleValid ? c.onAccent : c.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Validation Hint line
                    Center(
                      child: Text(
                        isTitleValid ? 'Saves to Pending' : 'A title is required',
                        style: DotoText.eyebrow.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: c.muted.withValues(alpha: 0.62),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
