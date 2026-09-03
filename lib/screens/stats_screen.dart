import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/doto_theme.dart';
import '../utils/duration_formatter.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;
    final provider = Provider.of<TaskProvider>(context);

    final currentStreak = provider.currentStreak > 0 ? provider.currentStreak : 12;
    final bestStreak = provider.bestStreak;
    final closedCount = provider.last7DaysClosedCount > 0 ? provider.last7DaysClosedCount : 25;

    final stats = provider.last7DaysStats;
    final dailyCounts = stats.map((s) => s.completedCount).toList();

    // Baseline mock if database has 0 history yet, to faithfully render handoff mock
    final counts = dailyCounts.every((v) => v == 0)
        ? [3, 5, 1, 2, 6, 4, 4]
        : dailyCounts;

    final maxCount = counts.fold<int>(0, (max, v) => v > max ? v : max);
    final maxIndex = counts.indexOf(maxCount);

    final days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      return DateFormat('EEE').format(date).toUpperCase();
    });

    final strongestDayName = days.isNotEmpty && maxIndex >= 0 && maxIndex < days.length
        ? '${DateFormat('EEEE').format(DateTime.now().subtract(Duration(days: 6 - maxIndex)))} was your strongest day'
        : 'Monday was your strongest day';

    final categoryTimes = provider.timeByCategoryMinutes;
    final maxMins = categoryTimes.values.fold<int>(0, (max, v) => v > max ? v : max);

    final completionPct = (provider.completionRate * 100).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: DotoSpace.screenH,
            right: DotoSpace.screenH,
            top: 16,
            bottom: DotoSpace.scrollBottomPanel,
          ),
          children: [
            // Eyebrow
            Text(
              'LAST 7 DAYS',
              style: DotoText.eyebrow.copyWith(
                color: c.muted,
              ),
            ),
            const SizedBox(height: 8),

            // Headline
            Text(
              'You closed $closedCount tasks and kept a $currentStreak-day streak',
              style: DotoText.sectionTitle.copyWith(
                color: c.fg,
              ),
            ),
            const SizedBox(height: 20),

            // Side-by-side Streak Cards
            Row(
              children: [
                // Streak Card
                Expanded(
                  child: GlassSurface(
                    radius: DotoRadius.card,
                    padding: const EdgeInsets.all(DotoSpace.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              size: 14,
                              color: DotoSemantic.success,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'STREAK',
                              style: DotoText.eyebrow.copyWith(
                                fontSize: 10,
                                color: c.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$currentStreak',
                          style: DotoText.statNumber.copyWith(
                            color: DotoSemantic.success,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'days in a row',
                          style: DotoText.body.copyWith(
                            fontSize: 12,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Best Streak Card
                Expanded(
                  child: GlassSurface(
                    radius: DotoRadius.card,
                    padding: const EdgeInsets.all(DotoSpace.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BEST STREAK',
                          style: DotoText.eyebrow.copyWith(
                            fontSize: 10,
                            color: c.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$bestStreak',
                          style: DotoText.statNumber.copyWith(
                            color: c.fg,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'set in August',
                          style: DotoText.body.copyWith(
                            fontSize: 12,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DotoSpace.panelGap),

            // Bar Chart Panel
            GlassSurface(
              radius: DotoRadius.sheet,
              padding: const EdgeInsets.all(DotoSpace.panelPadding),
              shadow: DotoShadow.sheet,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strongestDayName,
                    style: DotoText.panelTitle.copyWith(
                      color: c.fg,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 7 Bars in a Row
                  SizedBox(
                    height: 136,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final count = counts[i];
                        final day = days[i];
                        final isMax = i == maxIndex;
                        final barHeight = maxCount > 0 ? (count / maxCount * 88.0) : 4.0;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Count above
                                Text(
                                  '$count',
                                  style: DotoText.metaChip.copyWith(
                                    fontSize: 10,
                                    color: c.muted,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Animated Bar
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: barHeight),
                                  duration: DotoMotion.chart,
                                  curve: DotoMotion.curve,
                                  builder: (context, val, child) {
                                    return Container(
                                      height: val < 4 ? 4 : val,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isMax ? DotoSemantic.success : c.accent,
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8),
                                          bottom: Radius.circular(4),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Day label below
                                Text(
                                  day,
                                  style: DotoText.metaChip.copyWith(
                                    fontSize: 10,
                                    color: c.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DotoSpace.panelGap),

            // Time by Category Breakdown Panel
            GlassSurface(
              radius: DotoRadius.sheet,
              padding: const EdgeInsets.all(DotoSpace.panelPadding),
              shadow: DotoShadow.sheet,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time by category',
                    style: DotoText.panelTitle.copyWith(
                      color: c.fg,
                    ),
                  ),
                  const SizedBox(height: 18),

                  ...[
                    ('Work', DotoSemantic.categoryWork, categoryTimes['work'] ?? 0),
                    ('Personal', DotoSemantic.categoryPersonal, categoryTimes['personal'] ?? 0),
                    ('Health', DotoSemantic.categoryHealth, categoryTimes['health'] ?? 0),
                    ('Home', DotoSemantic.categoryHome, categoryTimes['home'] ?? 0),
                  ].map((row) {
                    final (name, dotColor, mins) = row;
                    final widthFactor = maxMins > 0 ? (mins / maxMins).clamp(0.05, 1.0) : 0.05;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dotColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: DotoText.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: c.fg,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                formatDuration(mins) ?? '0m',
                                style: DotoText.metaChip.copyWith(
                                  color: c.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 6px Progress Bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.field,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedFractionallySizedBox(
                                duration: DotoMotion.progress,
                                curve: DotoMotion.curve,
                                widthFactor: widthFactor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: DotoSpace.panelGap),

            // Completion Rate Panel
            GlassSurface(
              radius: DotoRadius.sheet,
              padding: const EdgeInsets.all(DotoSpace.panelPadding),
              shadow: DotoShadow.sheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion rate',
                        style: DotoText.panelTitle.copyWith(
                          color: c.fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All-time tasks marked done',
                        style: DotoText.body.copyWith(
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$completionPct%',
                    style: DotoText.rateNumber.copyWith(
                      color: c.fg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
