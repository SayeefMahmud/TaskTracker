import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/doto_theme.dart';
import '../models/task.dart';

class PriorityChipWidget extends StatelessWidget {
  final TaskPriority priority;
  final bool isSelected;
  final VoidCallback? onTap;

  const PriorityChipWidget({
    super.key,
    required this.priority,
    this.isSelected = false,
    this.onTap,
  });

  Color get dotColor {
    switch (priority) {
      case TaskPriority.high:
        return DotoSemantic.priorityHigh;
      case TaskPriority.medium:
        return DotoSemantic.priorityMedium;
      case TaskPriority.low:
        return DotoSemantic.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.selectionClick();
          onTap!();
        }
      },
      child: AnimatedContainer(
        duration: DotoMotion.control,
        curve: DotoMotion.curve,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? c.accent : c.chip,
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
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? c.onAccent : dotColor,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              priority.name.toUpperCase(),
              style: DotoText.priorityChip.copyWith(
                color: isSelected ? c.onAccent : c.fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
