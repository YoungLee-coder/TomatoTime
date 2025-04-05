import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  PomodoroSettings _settings = PomodoroSettings();

  PomodoroSettings get settings => _settings;

  // 初始化，加载设置
  Future<void> init() async {
    await loadSettings();
  }

  // 加载设置
  Future<void> loadSettings() async {
    _settings = await _settingsService.getSettings();
    notifyListeners();
  }

  // 更新设置
  Future<void> updateSettings(PomodoroSettings settings) async {
    _settings = settings;
    await _settingsService.saveSettings(settings);
    notifyListeners();
  }

  // 更新单个设置项
  Future<void> updateSetting({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    bool? darkMode,
  }) async {
    final newSettings = _settings.copyWith(
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      longBreakInterval: longBreakInterval,
      autoStartBreaks: autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      notificationsEnabled: notificationsEnabled,
      darkMode: darkMode,
    );

    await updateSettings(newSettings);
  }

  // 导出设置
  Future<String> exportSettings() async {
    final data = await _settingsService.exportData();
    return json.encode(data);
  }

  // 导入设置
  Future<bool> importSettings(String jsonData) async {
    try {
      final data = json.decode(jsonData);
      final success = await _settingsService.importData(data);

      if (success) {
        await loadSettings(); // 重新加载设置
        return true;
      }

      return false;
    } catch (e) {
      print('Error importing settings: $e');
      return false;
    }
  }
}
