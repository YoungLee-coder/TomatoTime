import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'sound_service.dart';
import 'vibration_service.dart';
import 'settings_service.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../models/settings.dart';

/// 服务定位器类
/// 负责集中管理和初始化应用的所有服务
class ServiceLocator {
  // 单例模式
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // 服务实例
  late final DatabaseService databaseService;
  late final NotificationService notificationService;
  late final SoundService soundService;
  late final VibrationService vibrationService;
  late final SettingsService settingsService;

  // 初始化所有服务
  Future<void> init() async {
    // 初始化基础服务
    databaseService = DatabaseService();
    notificationService = NotificationService();
    soundService = SoundService();
    vibrationService = VibrationService();
    settingsService = SettingsService();

    // 初始化通知服务
    await notificationService.initNotification();
  }

  // 创建所有Provider
  List<SingleChildWidget> getProviders() {
    return [
      // 基础服务提供者
      Provider<DatabaseService>.value(value: databaseService),
      Provider<NotificationService>.value(value: notificationService),
      Provider<SoundService>.value(value: soundService),
      Provider<VibrationService>.value(value: vibrationService),
      Provider<SettingsService>.value(value: settingsService),

      // 应用状态提供者
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => SettingsProvider(settingsService: settingsService),
      ),
      ChangeNotifierProvider<TaskProvider>(
        create: (_) => TaskProvider(databaseService: databaseService)..init(),
      ),

      // 这里需要先获取settings，因此使用ChangeNotifierProxyProvider
      ChangeNotifierProxyProvider<SettingsProvider, PomodoroProvider>(
        create:
            (context) => PomodoroProvider(
              settings: PomodoroSettings(), // 默认设置
              notificationService: notificationService,
              soundService: soundService,
              vibrationService: vibrationService,
              databaseService: databaseService,
            ),
        update:
            (context, settingsProvider, previous) =>
                previous!..setSettings(settingsProvider.settings),
      ),
    ];
  }
}
