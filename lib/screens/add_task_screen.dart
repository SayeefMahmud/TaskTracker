import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/doto_theme.dart';
import '../widgets/priority_chip.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({
    super.key,
    this.taskToEdit,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subtaskInputController = TextEditingController();

  // Timing controllers for Option 1 (relative offset)
  final _daysController = TextEditingController(text: '0');
  final _hoursController = TextEditingController(text: '1');
  final _minutesController = TextEditingController(text: '0');

  // Option 0: After now (relative), Option 1: Exact date & time
  int _timingMode = 0;

  // Option 2 state
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  TaskPriority _priority = TaskPriority.medium;
  TaskRecurrence _recurrence = TaskRecurrence.none;
  String _selectedCategory = 'work';
  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descController.text = task.description ?? '';
      _priority = task.priority;
      _recurrence = task.recurrence;
      if (task.categoryIds.isNotEmpty) {
        _selectedCategory = task.categoryIds.first;
      }
      _subtasks = task.subtasks
          .map((s) => Subtask(id: s.id, title: s.title, isCompleted: s.isCompleted))
          .toList();

      if (task.scheduledTime != null) {
        _selectedDate = task.scheduledTime!;
        _selectedTime = TimeOfDay(
          hour: task.scheduledTime!.hour,
          minute: task.scheduledTime!.minute,
        );
        // Default to Option 1 (Exact) when editing a task with existing scheduled time
        _timingMode = 1;

        final diff = task.scheduledTime!.difference(DateTime.now());
        if (!diff.isNegative) {
          final days = diff.inDays;
          final hours = diff.inHours % 24;
          final mins = diff.inMinutes % 60;
          _daysController.text = '$days';
          _hoursController.text = '$hours';
          _minutesController.text = '$mins';
        } else {
          _daysController.text = '0';
          _hoursController.text = '0';
          _minutesController.text = '30';
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _subtasks.add(Subtask(title: text));
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

  int get _relativeTotalMinutes {
    final d = int.tryParse(_daysController.text.trim()) ?? 0;
    final h = int.tryParse(_hoursController.text.trim()) ?? 0;
    final m = int.tryParse(_minutesController.text.trim()) ?? 0;
    return (d * 1440) + (h * 60) + m;
  }

  DateTime get _effectiveScheduledDateTime {
    if (_timingMode == 0) {
      final totalMins = _relativeTotalMinutes;
      return DateTime.now().add(Duration(minutes: totalMins > 0 ? totalMins : 0));
    } else {
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    }
  }

  bool get _isTimingValid {
    if (_timingMode == 0) {
      return _relativeTotalMinutes > 0;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;
    final isTitleValid = _titleController.text.trim().isNotEmpty;
    final isFormValid = isTitleValid && _isTimingValid;
    final isEditMode = widget.taskToEdit != null;

    final categories = [
      ('Work', DotoSemantic.categoryWork, 'work'),
      ('Personal', DotoSemantic.categoryPersonal, 'personal'),
      ('Health', DotoSemantic.categoryHealth, 'health'),
      ('Home', DotoSemantic.categoryHome, 'home'),
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

    final scheduledDateTime = _effectiveScheduledDateTime;
    final completedSubtasksCount = _subtasks.where((s) => s.isCompleted).length;
    final subtasksProgressFraction = _subtasks.isNotEmpty
        ? (completedSubtasksCount / _subtasks.length)
        : 0.0;

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
                      isEditMode ? 'Edit task' : 'Add task',
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
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: FractionallySizedBox(
                                                  widthFactor: subtasksProgressFraction,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: completedSubtasksCount == _subtasks.length
                                                          ? DotoSemantic.success
                                                          : c.accent,
                                                      borderRadius: BorderRadius.circular(999),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '$completedSubtasksCount/${_subtasks.length}',
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

                    // TIMING (2 selectable options: 1. Relative offset, 2. Exact date & time)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TIMING',
                          style: DotoText.fieldLabel.copyWith(color: c.muted),
                        ),
                        Text(
                          _timingMode == 0 ? 'Relative offset' : 'Exact date & time',
                          style: DotoText.metaChip.copyWith(color: c.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Mode Toggle Selector Pill
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.field,
                        borderRadius: BorderRadius.circular(DotoRadius.pill),
                        border: Border.all(color: c.edge, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _timingMode = 0);
                              },
                              child: AnimatedContainer(
                                duration: DotoMotion.control,
                                curve: DotoMotion.curve,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _timingMode == 0 ? c.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(DotoRadius.pill),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: _timingMode == 0 ? c.onAccent : c.muted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'After now',
                                      style: DotoText.tabLabel.copyWith(
                                        fontSize: 13,
                                        color: _timingMode == 0 ? c.onAccent : c.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _timingMode = 1);
                              },
                              child: AnimatedContainer(
                                duration: DotoMotion.control,
                                curve: DotoMotion.curve,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _timingMode == 1 ? c.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(DotoRadius.pill),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: _timingMode == 1 ? c.onAccent : c.muted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Exact time',
                                      style: DotoText.tabLabel.copyWith(
                                        fontSize: 13,
                                        color: _timingMode == 1 ? c.onAccent : c.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_timingMode == 0) ...[
                      // Option 1: X minutes Y hours Z days after now
                      Row(
                        children: [
                          // Days
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: c.field,
                                borderRadius: BorderRadius.circular(DotoRadius.input),
                                border: Border.all(color: c.edge, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DAYS',
                                    style: DotoText.eyebrow.copyWith(fontSize: 10, color: c.muted),
                                  ),
                                  TextField(
                                    controller: _daysController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    style: DotoText.cardTitle.copyWith(color: c.fg, fontSize: 16),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Hours
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: c.field,
                                borderRadius: BorderRadius.circular(DotoRadius.input),
                                border: Border.all(color: c.edge, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HOURS',
                                    style: DotoText.eyebrow.copyWith(fontSize: 10, color: c.muted),
                                  ),
                                  TextField(
                                    controller: _hoursController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    style: DotoText.cardTitle.copyWith(color: c.fg, fontSize: 16),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Minutes
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: c.field,
                                borderRadius: BorderRadius.circular(DotoRadius.input),
                                border: Border.all(color: c.edge, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MINUTES',
                                    style: DotoText.eyebrow.copyWith(fontSize: 10, color: c.muted),
                                  ),
                                  TextField(
                                    controller: _minutesController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    style: DotoText.cardTitle.copyWith(color: c.fg, fontSize: 16),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Quick helper chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            (15, '+15m'),
                            (30, '+30m'),
                            (60, '+1h'),
                            (120, '+2h'),
                            (1440, '+1d'),
                          ].map((preset) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  final totalMins = preset.$1;
                                  final d = totalMins ~/ 1440;
                                  final h = (totalMins % 1440) ~/ 60;
                                  final m = totalMins % 60;
                                  setState(() {
                                    _daysController.text = '$d';
                                    _hoursController.text = '$h';
                                    _minutesController.text = '$m';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: c.field,
                                    borderRadius: BorderRadius.circular(DotoRadius.pill),
                                    border: Border.all(color: c.edge, width: 1),
                                  ),
                                  child: Text(
                                    preset.$2,
                                    style: DotoText.metaChip.copyWith(fontSize: 11, color: c.fg),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ] else ...[
                      // Option 2: Exact date & time
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
                    ],
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
                      final sub = _subtasks[idx];
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
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    sub.isCompleted = !sub.isCompleted;
                                  });
                                },
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: sub.isCompleted ? c.accent : Colors.transparent,
                                    border: Border.all(
                                      color: sub.isCompleted ? c.accent : c.edge,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: sub.isCompleted
                                      ? Icon(Icons.check_rounded, size: 12, color: c.onAccent)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: DotoText.body.copyWith(
                                    color: sub.isCompleted ? c.fg.withValues(alpha: 0.5) : c.fg,
                                    decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
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

                    // SAVE / UPDATE TASK BUTTON
                    GestureDetector(
                      onTap: () async {
                        if (!isFormValid) return;
                        HapticFeedback.mediumImpact();

                        final targetScheduledTime = _effectiveScheduledDateTime;
                        final provider = Provider.of<TaskProvider>(context, listen: false);

                        if (isEditMode) {
                          final task = widget.taskToEdit!;
                          task.title = _titleController.text.trim();
                          task.description = _descController.text.trim().isEmpty
                              ? null
                              : _descController.text.trim();
                          task.scheduledTime = targetScheduledTime;
                          task.priority = _priority;
                          task.categoryIds = [_selectedCategory];
                          task.recurrence = _recurrence;
                          task.subtasks = _subtasks;
                          await provider.updateTask(task);
                        } else {
                          final newTask = Task(
                            title: _titleController.text.trim(),
                            description: _descController.text.trim().isEmpty
                                ? null
                                : _descController.text.trim(),
                            scheduledTime: targetScheduledTime,
                            priority: _priority,
                            categoryIds: [_selectedCategory],
                            recurrence: _recurrence,
                            subtasks: _subtasks,
                          );
                          await provider.addTask(newTask);
                          provider.setSelectedCategory('all');
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: AnimatedContainer(
                        duration: DotoMotion.control,
                        curve: DotoMotion.curve,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isFormValid ? c.accent : c.field.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(DotoRadius.pill),
                          border: Border.all(color: c.edge, width: 1),
                          boxShadow: isFormValid ? DotoShadow.save : null,
                        ),
                        child: Center(
                          child: Text(
                            isEditMode ? 'Save changes' : 'Save task',
                            style: DotoText.tabLabel.copyWith(
                              fontSize: 16,
                              color: isFormValid ? c.onAccent : c.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Validation Hint line
                    Center(
                      child: Text(
                        !isTitleValid
                            ? 'A title is required'
                            : !_isTimingValid
                                ? 'Timing must be at least 1 minute after now'
                                : isEditMode
                                    ? 'Saves changes to task'
                                    : 'Saves to Pending',
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
