import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/doto_theme.dart';

class DotoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const DotoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: DotoMotion.curve,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? c.accent : Colors.transparent,
            border: Border.all(
              color: value ? c.accent : c.edge,
              width: 1.5,
            ),
          ),
          child: value
              ? Icon(
                  Icons.check_rounded,
                  size: size * 0.65,
                  color: c.onAccent,
                )
              : null,
        ),
      ),
    );
  }
}

class DotoSubtaskCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DotoSubtaskCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: DotoMotion.curve,
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: value ? c.accent : Colors.transparent,
            border: Border.all(
              color: value ? c.accent : c.edge,
              width: 1.5,
            ),
          ),
          child: value
              ? Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: c.onAccent,
                )
              : null,
        ),
      ),
    );
  }
}
