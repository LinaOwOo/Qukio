import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _key = 'is_dark_mode';
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_key) ?? false;
      _mode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Если ошибка — используем системную тему
      _mode = ThemeMode.system;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = _mode == ThemeMode.dark;
      await prefs.setBool(_key, !now);
      _mode = now ? ThemeMode.light : ThemeMode.dark;
      notifyListeners();
    } catch (e) {
      // Игнорируем ошибку, но переключаем визуально
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      notifyListeners();
    }
  }

  bool get isDark => _mode == ThemeMode.dark;
}
