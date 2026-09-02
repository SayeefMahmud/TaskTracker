import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppThemes.neoWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: AppThemes.neoBlack, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppThemes.neoBlack),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.themeMode == ThemeMode.dark;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GestureDetector(
                onTap: () => themeProvider.toggleTheme(!isDark),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.neoBlue : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: AppThemes.neoBlack, offset: Offset(4, 4), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? AppThemes.neoYellow : AppThemes.neoPink,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppThemes.neoBlack, width: 2),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 22,
                          color: AppThemes.neoBlack,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppThemes.neoBlack,
                              ),
                            ),
                            Text(
                              isDark ? 'Currently on' : 'Currently off',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppThemes.neoBlack.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Neo toggle
                      Container(
                        width: 52,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark ? AppThemes.neoBlack : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppThemes.neoBlack, width: 2.5),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : AppThemes.neoBlack,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
