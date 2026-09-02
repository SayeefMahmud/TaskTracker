import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/doto_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;

    final items = [
      (Icons.menu_rounded, 'Tasks'),
      (Icons.bar_chart_rounded, 'Insights'),
      (Icons.wb_sunny_outlined, 'Settings'),
    ];

    return Positioned(
      left: DotoSpace.navInset,
      right: DotoSpace.navInset,
      bottom: DotoSpace.navBottom,
      height: DotoSpace.navHeight,
      child: GlassSurface(
        radius: DotoRadius.pill,
        sigma: 11,
        padding: const EdgeInsets.all(6),
        shadow: DotoShadow.nav,
        child: Row(
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final (icon, label) = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(index);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: DotoMotion.control,
                  curve: DotoMotion.curve,
                  decoration: BoxDecoration(
                    color: isSelected ? c.pill : Colors.transparent,
                    borderRadius: BorderRadius.circular(DotoRadius.pill),
                    boxShadow: isSelected ? DotoShadow.tabPill : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 17,
                          color: isSelected ? c.onPill : c.muted,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          label,
                          style: DotoText.navLabel.copyWith(
                            color: isSelected ? c.onPill : c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
