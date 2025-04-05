// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // 移除了FlutterLocalNotificationsPlugin的实例

  Future<void> initNotification() async {
    // 简化的初始化，未使用flutter_local_notifications
    debugPrint('通知服务初始化 - 当前版本不支持实际通知');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // 简化版本，仅打印通知信息
    debugPrint('通知显示: ID=$id, 标题=$title, 内容=$body');
  }

  Future<void> cancelNotification(int id) async {
    // 简化版本
    debugPrint('取消通知: ID=$id');
  }

  Future<void> cancelAllNotifications() async {
    // 简化版本
    debugPrint('取消所有通知');
  }

  Future<void> scheduleFocusEndNotification(int id, Duration duration) async {
    // 简化版本，仅打印计划信息
    debugPrint('计划专注结束通知: ID=$id, 持续时间=${duration.inMinutes}分钟');
  }

  Future<void> scheduleBreakEndNotification(int id, Duration duration) async {
    // 简化版本，仅打印计划信息
    debugPrint('计划休息结束通知: ID=$id, 持续时间=${duration.inMinutes}分钟');
  }
}
