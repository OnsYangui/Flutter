import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isDarkMode = false;

  ThemeProvider(this._prefs) {
    _isDarkMode = _prefs.getBool(AppConstants.prefThemeMode) ?? false;
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool(AppConstants.prefThemeMode, isDark);
    notifyListeners();
  }
}
