import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/doto_theme.dart';
import '../widgets/doto_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final isDark = themeProvider.isDark;
    final streakReminders = themeProvider.streakReminders;
    final rollOverRecurring = themeProvider.rollOverRecurring;

    final categories = [
      ('Work', DotoSemantic.categoryWork),
      ('Personal', DotoSemantic.categoryPersonal),
      ('Health', DotoSemantic.categoryHealth),
      ('Home', DotoSemantic.categoryHome),
    ];

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
              'PREFERENCES',
              style: DotoText.eyebrow.copyWith(
                color: c.muted,
              ),
            ),
            const SizedBox(height: 8),

            // Headline
            Text(
              'Settings',
              style: DotoText.sectionTitle.copyWith(
                color: c.fg,
              ),
            ),
            const SizedBox(height: 20),

            // Sheet 1 (Toggles)
            GlassSurface(
              radius: DotoRadius.sheet,
              padding: EdgeInsets.zero,
              shadow: DotoShadow.sheet,
              child: Column(
                children: [
                  // Dark Mode Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark mode',
                                style: DotoText.settingTitle.copyWith(color: c.fg),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isDark ? 'On — deep slate glass' : 'Off — daylight glass',
                                style: DotoText.body.copyWith(
                                  fontSize: 12.5,
                                  color: c.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DotoToggle(
                          value: isDark,
                          onChanged: (val) => themeProvider.toggleTheme(val),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: c.edge),

                  // Streak Reminders Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Streak reminders',
                                style: DotoText.settingTitle.copyWith(color: c.fg),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                streakReminders ? 'On — nudge me at 20:00' : 'Off',
                                style: DotoText.body.copyWith(
                                  fontSize: 12.5,
                                  color: c.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DotoToggle(
                          value: streakReminders,
                          onChanged: (val) => themeProvider.toggleStreakReminders(val),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: c.edge),

                  // Roll Over Recurring Tasks Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Roll over recurring tasks',
                                style: DotoText.settingTitle.copyWith(color: c.fg),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                rollOverRecurring ? 'On — missed repeats move to today' : 'Off',
                                style: DotoText.body.copyWith(
                                  fontSize: 12.5,
                                  color: c.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DotoToggle(
                          value: rollOverRecurring,
                          onChanged: (val) => themeProvider.toggleRollOverRecurring(val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DotoSpace.panelGap),

            // Sheet 2 (Overview & Counters)
            GlassSurface(
              radius: DotoRadius.sheet,
              padding: EdgeInsets.zero,
              shadow: DotoShadow.sheet,
              child: Column(
                children: [
                  // Categories Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Categories',
                              style: DotoText.settingTitle.copyWith(color: c.fg),
                            ),
                            Text(
                              '${categories.length}',
                              style: DotoText.counter.copyWith(
                                fontSize: 14.5,
                                color: c.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((cat) {
                            final (name, dotColor) = cat;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: c.field,
                                borderRadius: BorderRadius.circular(DotoRadius.pill),
                                border: Border.all(color: c.edge, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dotColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    name,
                                    style: DotoText.navLabel.copyWith(
                                      color: c.fg,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: c.edge),

                  // Completed Tasks Counter Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completed tasks',
                          style: DotoText.settingTitle.copyWith(color: c.fg),
                        ),
                        Text(
                          '${taskProvider.totalCompletedCount > 0 ? taskProvider.totalCompletedCount : 2}',
                          style: DotoText.counter.copyWith(
                            fontSize: 14.5,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Footer Version Info
            Center(
              child: Text(
                'DOTO  v2.0  ·  SPATIAL',
                style: DotoText.metaChip.copyWith(
                  fontSize: 10.5,
                  letterSpacing: 1.2,
                  color: c.muted.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
