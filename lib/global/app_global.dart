import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/settings_service.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/pomodoro_provider.dart';

/// AppGlobal 类
/// 提供一种简化的方式来访问应用中的服务和Provider
class AppGlobal {
  // 私有构造函数，防止直接实例化
  AppGlobal._();

  /// 获取数据库服务
  static DatabaseService getDatabaseService(BuildContext context) {
    return Provider.of<DatabaseService>(context, listen: false);
  }

  /// 获取通知服务
  static NotificationService getNotificationService(BuildContext context) {
    return Provider.of<NotificationService>(context, listen: false);
  }

  /// 获取声音服务
  static SoundService getSoundService(BuildContext context) {
    return Provider.of<SoundService>(context, listen: false);
  }

  /// 获取振动服务
  static VibrationService getVibrationService(BuildContext context) {
    return Provider.of<VibrationService>(context, listen: false);
  }

  /// 获取设置服务
  static SettingsService getSettingsService(BuildContext context) {
    return Provider.of<SettingsService>(context, listen: false);
  }

  /// 获取设置Provider
  static SettingsProvider getSettingsProvider(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<SettingsProvider>(context, listen: listen);
  }

  /// 获取任务Provider
  static TaskProvider getTaskProvider(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<TaskProvider>(context, listen: listen);
  }

  /// 获取番茄钟Provider
  static PomodoroProvider getPomodoroProvider(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<PomodoroProvider>(context, listen: listen);
  }
}
