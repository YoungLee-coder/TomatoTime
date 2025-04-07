import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 判断是否支持通知的平台
  bool get _isNotificationSupported =>
      !Platform.isWindows && !Platform.isLinux && !Platform.isMacOS;

  // 初始化通知服务
  Future<void> initNotification() async {
    // 初始化时区数据
    tz_data.initializeTimeZones();

    // 检查是否是支持通知的平台
    if (!_isNotificationSupported) {
      debugPrint('当前平台不支持通知功能');
      return;
    }

    // 只在移动平台请求通知权限
    if (Platform.isAndroid || Platform.isIOS) {
      await _requestNotificationPermission();
    }

    // Android设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS设置
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    // 通知初始化设置
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // 初始化通知插件
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    debugPrint('通知服务初始化成功');
  }

  // 检查并请求通知权限
  Future<void> _requestNotificationPermission() async {
    // 检查通知权限
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      // 请求通知权限
      await Permission.notification.request();
    }
  }

  // 处理通知响应
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('用户点击了通知: ${response.payload}');
  }

  // 显示普通通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // 检查平台支持
    if (!_isNotificationSupported) {
      debugPrint('在不支持通知的平台上尝试显示通知，操作已跳过');
      return;
    }

    // 创建Android通知详情
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
          'pomodoro_channel', // 渠道ID
          '番茄时间通知', // 渠道名称
          channelDescription: '番茄时间应用的通知', // 渠道描述
          importance: Importance.high, // 重要性
          priority: Priority.high, // 优先级
          showWhen: true, // 显示通知时间
          autoCancel: true, // 点击后自动取消
          enableVibration: true, // 允许震动
          playSound: true, // 允许声音
        );

    // 创建iOS通知详情
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
          presentAlert: true, // 前台显示通知
          presentBadge: true, // 显示角标
          presentSound: true, // 播放声音
        );

    // 创建通知详情
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // 显示通知
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    debugPrint('通知显示: ID=$id, 标题=$title, 内容=$body');
  }

  // 取消指定ID的通知
  Future<void> cancelNotification(int id) async {
    if (!_isNotificationSupported) {
      debugPrint('在不支持通知的平台上尝试取消通知，操作已跳过');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('取消通知: ID=$id');
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    if (!_isNotificationSupported) {
      debugPrint('在不支持通知的平台上尝试取消所有通知，操作已跳过');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('取消所有通知');
  }

  // 安排专注结束通知
  Future<void> scheduleFocusEndNotification(int id, Duration duration) async {
    if (!_isNotificationSupported) {
      debugPrint('在不支持通知的平台上尝试安排专注结束通知，操作已跳过');
      return;
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(duration);

    // 创建Android通知详情
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
          'pomodoro_scheduled_channel',
          '番茄时间计划通知',
          channelDescription: '番茄时间应用的计划通知',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          autoCancel: true,
          enableVibration: true,
          playSound: true,
          fullScreenIntent: true, // 使用全屏意图（可在锁屏界面显示）
        );

    // 创建iOS通知详情
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active, // 使用活跃中断级别，可在勿扰模式下显示
        );

    // 创建通知详情
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // 安排通知
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '专注结束',
      '恭喜完成一个番茄钟！现在可以休息一下了。',
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'focus_end',
    );

    debugPrint('计划专注结束通知: ID=$id, 持续时间=${duration.inMinutes}分钟');
  }

  // 安排休息结束通知
  Future<void> scheduleBreakEndNotification(int id, Duration duration) async {
    if (!_isNotificationSupported) {
      debugPrint('在不支持通知的平台上尝试安排休息结束通知，操作已跳过');
      return;
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(duration);

    // 创建Android通知详情
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
          'pomodoro_scheduled_channel',
          '番茄时间计划通知',
          channelDescription: '番茄时间应用的计划通知',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          autoCancel: true,
          enableVibration: true,
          playSound: true,
          fullScreenIntent: true,
        );

    // 创建iOS通知详情
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active,
        );

    // 创建通知详情
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // 安排通知
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '休息结束',
      '休息时间结束了，准备开始下一个番茄钟吧！',
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'break_end',
    );

    debugPrint('计划休息结束通知: ID=$id, 持续时间=${duration.inMinutes}分钟');
  }
}
