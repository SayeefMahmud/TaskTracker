import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../theme.dart';
import '../utils/duration_formatter.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedDuration;
  TaskPriority _priority = TaskPriority.medium;
  TaskRecurrence _recurrence = TaskRecurrence.none;
  
  final List<TextEditingController> _subtaskControllers = [];
  final List<String> _selectedCategoryIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final ctrl in _subtaskControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Color _priorityCardColor() {
    switch (_priority) {
      case TaskPriority.high:
        return AppThemes.neoYellow;
      case TaskPriority.medium:
        return AppThemes.neoBlue;
      case TaskPriority.low:
        return AppThemes.neoMint;
    }
  }

  InputDecoration _neoInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppThemes.neoBlack,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemes.neoBlack, width: 2.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemes.neoBlack, width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemes.neoBlack, width: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
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
                child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppThemes.neoBlack),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Preview card
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _priorityCardColor(),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppThemes.neoBlack, width: 2.5),
              boxShadow: const [
                BoxShadow(color: AppThemes.neoBlack, offset: Offset(4, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.isEmpty ? 'Task title...' : _titleController.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _titleController.text.isEmpty
                        ? AppThemes.neoBlack.withValues(alpha: 0.3)
                        : AppThemes.neoBlack,
                  ),
                ),
                if (_descController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _descController.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppThemes.neoBlack.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedDate != null && _selectedTime != null)
                      _NeoChip(label: '⏰ ${DateFormat('MMM d').format(_selectedDate!)}, ${_selectedTime!.format(context)}'),
                    if (_selectedDuration != null && _selectedDuration! > 0)
                      _NeoChip(label: '⏳ ${formatDuration(_selectedDuration)}'),
                    _NeoChip(
                      label: _priority.name.toUpperCase(),
                      bgColor: _priority == TaskPriority.high ? AppThemes.neoRed : Colors.white,
                      textColor: _priority == TaskPriority.high ? Colors.white : AppThemes.neoBlack,
                    ),
                    if (_recurrence != TaskRecurrence.none)
                      _NeoChip(label: '🔁 ${_recurrence.name.toUpperCase()}'),
                    if (_subtaskControllers.isNotEmpty)
                      _NeoChip(label: '0/${_subtaskControllers.length} Sub'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _titleController,
            decoration: _neoInputDecoration('Title'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _descController,
            decoration: _neoInputDecoration('Description (Optional)'),
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Date & Time picker
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null && context.mounted) {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = time;
                  });
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                boxShadow: const [BoxShadow(color: AppThemes.neoBlack, offset: Offset(3, 3), blurRadius: 0)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20, color: AppThemes.neoBlack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          _selectedDate == null
                              ? 'Not set'
                              : '${DateFormat('MMM d, yyyy').format(_selectedDate!)} at ${_selectedTime?.format(context) ?? ''}',
                          style: TextStyle(fontSize: 13, color: AppThemes.neoBlack.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppThemes.neoBlack),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Recurrence
          DropdownButtonFormField<TaskRecurrence>(
            value: _recurrence,
            decoration: _neoInputDecoration('Repeat'),
            items: TaskRecurrence.values.map((r) {
              return DropdownMenuItem(value: r, child: Text(r.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700)));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _recurrence = val);
            },
          ),
          const SizedBox(height: 16),

          // Duration selector
          const Text('Duration', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppThemes.neoBlack)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDurationChip(null, 'None'),
                _buildDurationChip(15, '15m'),
                _buildDurationChip(30, '30m'),
                _buildDurationChip(60, '1h'),
                _buildDurationChip(120, '2h'),
                _buildDurationCustomChip(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Priority selector
          const Text('Priority', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppThemes.neoBlack)),
          const SizedBox(height: 10),
          Row(
            children: TaskPriority.values.map((p) {
              final isSelected = _priority == p;
              Color chipColor = p == TaskPriority.high ? AppThemes.neoYellow : (p == TaskPriority.medium ? AppThemes.neoBlue : AppThemes.neoMint);
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? chipColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                      boxShadow: isSelected ? const [BoxShadow(color: AppThemes.neoBlack, offset: Offset(3, 3), blurRadius: 0)] : [],
                    ),
                    child: Text(
                      p.name.toUpperCase(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppThemes.neoBlack, letterSpacing: 0.5),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Subtasks
          const Text('Subtasks', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppThemes.neoBlack)),
          const SizedBox(height: 10),
          ..._subtaskControllers.asMap().entries.map((entry) {
            final idx = entry.key;
            final ctrl = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: _neoInputDecoration('Subtask ${idx + 1}').copyWith(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      onChanged: (_) => setState((){}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() => _subtaskControllers.removeAt(idx)),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() => _subtaskControllers.add(TextEditingController())),
            icon: const Icon(Icons.add, color: AppThemes.neoBlack),
            label: const Text('Add Subtask', style: TextStyle(color: AppThemes.neoBlack, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 32),

          // Save button
          GestureDetector(
            onTap: () {
              if (_titleController.text.trim().isEmpty) return;

              DateTime? scheduledTime;
              if (_selectedDate != null && _selectedTime != null) {
                scheduledTime = DateTime(
                  _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                  _selectedTime!.hour, _selectedTime!.minute,
                );
              }
              
              final validSubtasks = _subtaskControllers
                .where((c) => c.text.trim().isNotEmpty)
                .map((c) => Subtask(title: c.text.trim()))
                .toList();

              final task = Task(
                title: _titleController.text.trim(),
                description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                scheduledTime: scheduledTime,
                priority: _priority,
                recurrence: _recurrence,
                subtasks: validSubtasks,
                categoryIds: _selectedCategoryIds,
                durationMinutes: (_selectedDuration != null && _selectedDuration! > 0) ? _selectedDuration : null,
              );

              Provider.of<TaskProvider>(context, listen: false).addTask(task);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppThemes.neoBlack,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                boxShadow: const [BoxShadow(color: Color(0xFF888888), offset: Offset(4, 4), blurRadius: 0)],
              ),
              child: const Center(
                child: Text(
                  'Save Task',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDurationChip(int? duration, String label) {
    final isSelected = _selectedDuration == duration;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedDuration = duration),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppThemes.neoBlack : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppThemes.neoBlack, width: 2.5),
            boxShadow: isSelected ? const [BoxShadow(color: Color(0xFF888888), offset: Offset(3, 3), blurRadius: 0)] : [],
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : AppThemes.neoBlack, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationCustomChip() {
    final isCustom = _selectedDuration != null && ![null, 15, 30, 60, 120].contains(_selectedDuration);
    final label = isCustom ? formatDuration(_selectedDuration)! : 'Custom';
    
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () async {
          final custom = await _showCustomDurationDialog();
          if (custom != null) {
            setState(() => _selectedDuration = custom);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isCustom ? AppThemes.neoBlack : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppThemes.neoBlack, width: 2.5),
            boxShadow: isCustom ? const [BoxShadow(color: Color(0xFF888888), offset: Offset(3, 3), blurRadius: 0)] : [],
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isCustom ? Colors.white : AppThemes.neoBlack, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Future<int?> _showCustomDurationDialog() async {
    int? result;
    final controller = TextEditingController(text: _selectedDuration?.toString() ?? '');
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.neoWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppThemes.neoBlack, width: 3),
          ),
          title: const Text('Custom Duration (min)', style: TextStyle(fontWeight: FontWeight.w900)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: _neoInputDecoration('Minutes'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: AppThemes.neoBlack, fontWeight: FontWeight.w800)),
            ),
            TextButton(
              onPressed: () {
                result = int.tryParse(controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: AppThemes.neoBlack, fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
    return result;
  }
}

class _NeoChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _NeoChip({
    required this.label,
    this.bgColor = Colors.white,
    this.textColor = AppThemes.neoBlack,
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 0.5),
      ),
    );
  }
}
