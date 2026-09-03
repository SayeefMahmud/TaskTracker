import 'package:flutter/material.dart';
import '../theme/doto_theme.dart';

class EmptyStateView extends StatelessWidget {
  final bool isCompletedTab;

  const EmptyStateView({
    super.key,
    required this.isCompletedTab,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;

    final title = isCompletedTab ? 'Nothing done yet' : 'Nothing floating';
    final body = isCompletedTab
        ? 'Completed tasks settle here.'
        : 'This layer is clear. Tap + to add a task.';

    return Center(
      child: GlassSurface(
        radius: DotoRadius.emptyState,
        sigma: 9,
        fill: c.glassSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.field,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 24,
                color: c.fg,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: DotoText.cardTitle.copyWith(
                fontSize: 18,
                color: c.fg,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: DotoText.body.copyWith(
                color: c.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
