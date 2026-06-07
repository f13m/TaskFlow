import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;  // افتراضي: يتبع النظام
  bool _isDarkMode = false;  // للواجهة فقط

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();  // تحميل الثيم المحفوظ عند البدء
  }

  // تبديل الثيم (فاتح/داكن/نظام)
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = (mode == ThemeMode.dark) || 
                  (mode == ThemeMode.system && 
                   WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    notifyListeners();
    _saveTheme();  // حفظ الثيم في SharedPreferences
  }

  // تبديل بين الفاتح والداكن (للـ Switch في البروفايل)
  void toggleDarkMode(bool value) {
    setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // حفظ الثيم
  void _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeMode.name);
  }

  // تحميل الثيم المحفوظ
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('themeMode');
    if (savedMode != null) {
      setThemeMode(ThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => ThemeMode.system,
      ));
    }
  }
}