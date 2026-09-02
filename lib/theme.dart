import 'package:flutter/material.dart';

class AppThemes {
  // Neobrutalist color constants
  static const Color neoBlack = Color(0xFF1a1a1a);
  static const Color neoWhite = Color(0xFFFFFDF7);
  static const Color neoYellow = Color(0xFFFFEB99);
  static const Color neoMint = Color(0xFFC5F0C2);
  static const Color neoBlue = Color(0xFFBDE0FE);
  static const Color neoPink = Color(0xFFF8C8DC);
  static const Color neoRed = Color(0xFFFF5252);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.blue,
    scaffoldBackgroundColor: neoWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: neoWhite,
      foregroundColor: neoBlack,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: neoBlack,
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorSchemeSeed: Colors.teal,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
  );
}
