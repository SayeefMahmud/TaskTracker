import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _streakReminders = true;
  bool _rollOverRecurring = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get streakReminders => _streakReminders;
  bool get rollOverRecurring => _rollOverRecurring;

  void toggleTheme(bool dark) {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleStreakReminders(bool value) {
    _streakReminders = value;
    if (_streakReminders) {
      NotificationService().scheduleDailySummaryTask();
    } else {
      NotificationService().cancelDailySummaryTask();
    }
    notifyListeners();
  }

  void toggleRollOverRecurring(bool value) {
    _rollOverRecurring = value;
    notifyListeners();
  }
}
