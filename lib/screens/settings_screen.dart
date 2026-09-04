import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
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
            const SizedBox(height: DotoSpace.panelGap),

            // Sheet 3 (Reminder delivery diagnostics)
            const _ReminderDiagnostics(),
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

/// Shows what the OS actually thinks about this app's reminders. Android can
/// refuse a notification or an exact alarm silently, so the state that decides
/// whether a reminder ever fires is reported here rather than only in the log.
class _ReminderDiagnostics extends StatefulWidget {
  const _ReminderDiagnostics();

  @override
  State<_ReminderDiagnostics> createState() => _ReminderDiagnosticsState();
}

class _ReminderDiagnosticsState extends State<_ReminderDiagnostics> {
  final NotificationService _notifications = NotificationService();

  bool _loading = true;
  bool _notificationsEnabled = false;
  bool _exactAlarms = false;
  int _pending = -1;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final enabled = await _notifications.areNotificationsEnabled();
    final exact = await _notifications.canScheduleExactAlarms();
    final pending = await _notifications.pendingNotificationCount();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _exactAlarms = exact;
      _pending = pending;
      _loading = false;
    });
  }

  Future<void> _sendTest() async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await _notifications.sendTestNotification();
    await _refresh();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(error == null
            ? 'Test reminder posted — check your notification shade.'
            : 'Could not post: $error'),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;

    return GlassSurface(
      radius: DotoRadius.sheet,
      padding: EdgeInsets.zero,
      shadow: DotoShadow.sheet,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 19, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reminders',
                      style: DotoText.settingTitle.copyWith(color: c.fg),
                    ),
                    GestureDetector(
                      onTap: _loading ? null : _refresh,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'REFRESH',
                        style: DotoText.metaChip.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 1.2,
                          color: c.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_loading)
                  Text(
                    'Checking…',
                    style: DotoText.body.copyWith(fontSize: 12.5, color: c.muted),
                  )
                else ...[
                  _statusLine(c, 'Notifications allowed', _notificationsEnabled,
                      _notificationsEnabled ? 'Yes' : 'Blocked in system settings'),
                  _statusLine(c, 'Exact alarms allowed', _exactAlarms,
                      _exactAlarms
                          ? 'Yes — reminders fire on the second'
                          : 'No — reminders may be delayed by Doze'),
                  _statusLine(c, 'Scheduled reminders', _pending > 0,
                      _pending < 0 ? 'Unavailable' : '$_pending queued'),
                ],
                ValueListenableBuilder<String?>(
                  valueListenable: NotificationService.lastError,
                  builder: (context, error, _) {
                    if (error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Last failure — $error',
                        style: DotoText.body.copyWith(
                          fontSize: 12,
                          color: DotoSemantic.priorityHigh,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: c.edge),
          GestureDetector(
            onTap: _sendTest,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Send a test reminder',
                    style: DotoText.settingTitle.copyWith(color: c.fg),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: c.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLine(DotoColors c, String label, bool ok, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5, right: 8),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? DotoSemantic.categoryHealth : DotoSemantic.priorityMedium,
            ),
          ),
          Expanded(
            child: Text(
              '$label — $value',
              style: DotoText.body.copyWith(fontSize: 12.5, color: c.muted),
            ),
          ),
        ],
      ),
    );
  }
}
