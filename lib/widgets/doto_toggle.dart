import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/doto_theme.dart';

class DotoToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DotoToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final offTrackColor = isDark ? const Color(0x24FFFFFF) : const Color(0x80FFFFFF);
    final onTrackColor = isDark ? c.accent.withValues(alpha: 0.35) : c.accent.withValues(alpha: 0.22);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: DotoMotion.toggle,
        curve: DotoMotion.curve,
        width: 54,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? onTrackColor : offTrackColor,
          borderRadius: BorderRadius.circular(DotoRadius.pill),
          border: Border.all(color: c.edge, width: 1),
        ),
        child: AnimatedAlign(
          duration: DotoMotion.toggle,
          curve: DotoMotion.curve,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? c.accent : (isDark ? Colors.white.withValues(alpha: 0.8) : Colors.white),
              boxShadow: DotoShadow.knob,
            ),
          ),
        ),
      ),
    );
  }
}
