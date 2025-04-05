import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/pomodoro_history.dart';
import '../models/settings.dart';
import '../models/user_profile.dart';
import 'database_service.dart';
import 'settings_service.dart';
import 'user_service.dart';

class BackupService {
  final DatabaseService _databaseService = DatabaseService();
  final SettingsService _settingsService = SettingsService();
  final UserService _userService = UserService();

  // 创建备份
  Future<String?> createBackup() async {
    if (kIsWeb) {
      throw UnimplementedError('Web平台不支持本地备份');
    }

    try {
      // 收集所有需要备份的数据
      final backupData = await _collectBackupData();

      // 创建备份文件
      final backupJson = jsonEncode(backupData);

      // 获取存储目录
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFile = File(
        '${directory.path}/pomodoro_backup_$timestamp.json',
      );

      // 写入备份数据
      await backupFile.writeAsString(backupJson);

      return backupFile.path;
    } catch (e) {
      debugPrint('创建备份失败: $e');
      return null;
    }
  }

  // 从备份恢复
  Future<bool> restoreFromBackup(File backupFile) async {
    if (kIsWeb) {
      throw UnimplementedError('Web平台不支持本地恢复');
    }

    try {
      // 读取备份文件
      final backupJson = await backupFile.readAsString();
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;

      // 恢复所有数据
      await _restoreBackupData(backupData);

      return true;
    } catch (e) {
      debugPrint('从备份恢复失败: $e');
      return false;
    }
  }

  // 收集备份数据
  Future<Map<String, dynamic>> _collectBackupData() async {
    // 收集用户资料
    final userProfile = await _userService.getUserProfile();

    // 收集设置
    final settings = await _settingsService.getSettings();

    // 在Web平台上，我们使用模拟数据，否则从数据库获取真实数据
    List<Task> tasks = [];
    List<PomodoroHistory> history = [];

    if (!kIsWeb) {
      // 收集任务数据
      tasks = await _databaseService.getTasks();

      // 收集历史记录
      history = await _databaseService.getPomodoroHistory();
    }

    // 构建备份数据
    return {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'userProfile': userProfile.toJson(),
      'settings': settings.toJson(),
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'history': history.map((item) => item.toMap()).toList(),
    };
  }

  // 恢复备份数据
  Future<void> _restoreBackupData(Map<String, dynamic> backupData) async {
    try {
      // 恢复用户资料
      if (backupData.containsKey('userProfile')) {
        final userProfile = UserProfile.fromJson(
          backupData['userProfile'] as Map<String, dynamic>,
        );
        await _userService.saveUserProfile(userProfile);
      }

      // 恢复设置
      if (backupData.containsKey('settings')) {
        final settings = PomodoroSettings.fromJson(
          backupData['settings'] as Map<String, dynamic>,
        );
        await _settingsService.saveSettings(settings);
      }

      // 如果不是Web平台，恢复数据库数据
      if (!kIsWeb) {
        // 恢复任务数据
        if (backupData.containsKey('tasks')) {
          final tasksData = backupData['tasks'] as List<dynamic>;

          // 先清除现有任务
          await _clearTasks();

          // 添加备份中的任务
          for (final taskData in tasksData) {
            final task = Task.fromMap(taskData as Map<String, dynamic>);
            await _databaseService.insertTask(task);
          }
        }

        // 恢复历史记录
        if (backupData.containsKey('history')) {
          final historyData = backupData['history'] as List<dynamic>;

          // 先清除现有历史记录
          await _clearHistory();

          // 添加备份中的历史记录
          for (final historyItem in historyData) {
            final history = PomodoroHistory.fromMap(
              historyItem as Map<String, dynamic>,
            );
            await _databaseService.insertPomodoroHistory(history);
          }
        }
      }
    } catch (e) {
      debugPrint('恢复备份数据失败: $e');
      rethrow;
    }
  }

  // 清除所有任务
  Future<void> _clearTasks() async {
    try {
      final db = await _databaseService.database;
      await db.delete('tasks');
    } catch (e) {
      debugPrint('清除任务失败: $e');
      rethrow;
    }
  }

  // 清除所有历史记录
  Future<void> _clearHistory() async {
    try {
      final db = await _databaseService.database;
      await db.delete('pomodoro_history');
    } catch (e) {
      debugPrint('清除历史记录失败: $e');
      rethrow;
    }
  }

  // 获取所有备份文件
  Future<List<File>> getBackupFiles() async {
    if (kIsWeb) {
      return [];
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);
      final entities = await dir.list().toList();

      return entities
          .whereType<File>()
          .where(
            (file) =>
                file.path.contains('pomodoro_backup_') &&
                file.path.endsWith('.json'),
          )
          .toList();
    } catch (e) {
      debugPrint('获取备份文件失败: $e');
      return [];
    }
  }

  // 删除备份文件
  Future<bool> deleteBackupFile(File backupFile) async {
    if (kIsWeb) {
      return false;
    }

    try {
      if (await backupFile.exists()) {
        await backupFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('删除备份文件失败: $e');
      return false;
    }
  }
}
