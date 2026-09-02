import 'package:flutter/material.dart';
import '../theme/doto_theme.dart';
import '../widgets/floating_nav_bar.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DotoBackdrop(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ],
        ),
      ),
    );
  }
}
