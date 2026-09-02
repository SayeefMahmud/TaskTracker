import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/doto_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.dotColor,
    this.isSelected = false,
    this.onTap,
  });

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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.accent : c.glass,
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
              label,
              style: DotoText.navLabel.copyWith(
                fontSize: 12.5,
                color: isSelected ? c.onAccent : c.fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
