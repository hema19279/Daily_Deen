import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_colors.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (_isDarkMode) {
      AppColors.resetToDarkMode();
    } else {
      AppColors.resetToDefault();
    }

    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);

    if (value) {
      AppColors.resetToDarkMode();
    } else {
      AppColors.resetToDefault();
    }

    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }
}
