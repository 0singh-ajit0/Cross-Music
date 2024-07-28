import 'package:flutter/material.dart';

import 'app_pallete.dart';

class AppTheme {
  static OutlineInputBorder _border({required Color color}) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      focusedBorder: _border(color: Pallete.gradient2),
      enabledBorder: _border(color: Pallete.borderColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Pallete.backgroundColor,
    ),
  );
}
