import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsService {
  static const String settingsKey = 'pomodoro_settings';

  Future<PomodoroSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(settingsKey);

    if (settingsJson == null) {
      return PomodoroSettings(); // 返回默认设置
    }

    try {
      final Map<String, dynamic> settingsMap = json.decode(settingsJson);
      return PomodoroSettings.fromMap(settingsMap);
    } catch (e) {
      print('Error loading settings: $e');
      return PomodoroSettings(); // 出错时返回默认设置
    }
  }

  Future<void> saveSettings(PomodoroSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsJson = json.encode(settings.toMap());
    await prefs.setString(settingsKey, settingsJson);
  }

  // 备份设置和所有数据
  Future<Map<String, dynamic>> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(settingsKey);

    // 获取所有共享首选项数据
    final allPrefs = prefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
      dynamic value;
      if (prefs.getString(key) != null) {
        value = prefs.getString(key);
      } else if (prefs.getBool(key) != null) {
        value = prefs.getBool(key);
      } else if (prefs.getInt(key) != null) {
        value = prefs.getInt(key);
      } else if (prefs.getDouble(key) != null) {
        value = prefs.getDouble(key);
      } else if (prefs.getStringList(key) != null) {
        value = prefs.getStringList(key);
      }

      if (value != null) {
        map[key] = value;
      }
      return map;
    });

    return {
      'settings': settingsJson != null ? json.decode(settingsJson) : null,
      'preferences': allPrefs,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // 恢复设置和所有数据
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 恢复设置
      if (data['settings'] != null) {
        final settingsJson = json.encode(data['settings']);
        await prefs.setString(settingsKey, settingsJson);
      }

      // 恢复所有共享首选项数据
      if (data['preferences'] != null && data['preferences'] is Map) {
        final Map<String, dynamic> preferences = data['preferences'];
        for (final entry in preferences.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is String) {
            await prefs.setString(key, value);
          } else if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is List) {
            await prefs.setStringList(
              key,
              value.map((e) => e.toString()).toList(),
            );
          }
        }
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }
}
