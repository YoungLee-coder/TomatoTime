import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService;
  PomodoroSettings _settings = PomodoroSettings();

  // 构造函数接收依赖
  SettingsProvider({SettingsService? settingsService})
    : _settingsService = settingsService ?? SettingsService();

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
    AppThemeMode? themeMode,
    AppThemeColor? themeColor,
    bool? keepScreenAwake,
  }) async {
    _settings = _settings.copyWith(
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      longBreakInterval: longBreakInterval,
      autoStartBreaks: autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      notificationsEnabled: notificationsEnabled,
      themeMode: themeMode,
      themeColor: themeColor,
      keepScreenAwake: keepScreenAwake,
    );
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  // 更新主题模式
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    await updateSetting(themeMode: themeMode);
  }

  // 更新主题颜色
  void updateThemeColor(AppThemeColor themeColor) {
    _settings = _settings.copyWith(themeColor: themeColor);
    updateSetting();
    notifyListeners();
  }

  // 更新屏幕常亮设置
  void updateKeepScreenAwake(bool keepScreenAwake) {
    _settings = _settings.copyWith(keepScreenAwake: keepScreenAwake);
    updateSetting();
    notifyListeners();
  }

  // 获取Flutter的ThemeMode
  ThemeMode getFlutterThemeMode() {
    switch (_settings.themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  // 获取当前实际的主题模式（考虑系统设置）
  bool isDarkMode(BuildContext context) {
    if (_settings.themeMode == AppThemeMode.system) {
      // 获取系统主题模式
      final brightness = MediaQuery.platformBrightnessOf(context);
      return brightness == Brightness.dark;
    }
    return _settings.themeMode == AppThemeMode.dark;
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
