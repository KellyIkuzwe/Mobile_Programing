import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModePreference {
  Light,
  Dark,
}

class ThemePreferences {
  static const String _themeKey = 'theme_preference';

  // Get the current saved theme mode
  Future<ThemeModePreference> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt(_themeKey) ?? ThemeModePreference.Light.index;
    return ThemeModePreference.values[themeIndex];
  }

  // Save the selected theme mode
  Future<void> setThemeMode(ThemeModePreference themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }
}