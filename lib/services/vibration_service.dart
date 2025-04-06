import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 振动服务类，负责管理应用内的振动功能
class VibrationService {
  // 检查设备是否支持振动
  // 注意：HapticFeedback没有直接的检查方法，所以默认假定设备支持
  Future<bool> hasVibrator() async {
    // Web平台不支持振动
    if (kIsWeb) {
      debugPrint('Web平台不支持振动');
      return false;
    }

    return true;
  }

  // 触发简单振动
  Future<void> vibrate() async {
    // Web平台不支持振动
    if (kIsWeb) {
      debugPrint('Web平台不支持振动，跳过');
      return;
    }

    try {
      // 使用中等强度反馈
      await HapticFeedback.mediumImpact();
      debugPrint('触发简单振动');
    } catch (e) {
      debugPrint('触发振动失败: $e');
    }
  }

  // 专注结束振动
  Future<void> vibrateFocusEnd() async {
    // Web平台不支持振动
    if (kIsWeb) {
      debugPrint('Web平台不支持振动，跳过');
      return;
    }

    try {
      // 使用多次振动模拟多种模式
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      debugPrint('触发专注结束振动');
    } catch (e) {
      debugPrint('触发专注结束振动失败: $e');
    }
  }

  // 休息结束振动
  Future<void> vibrateBreakEnd() async {
    // Web平台不支持振动
    if (kIsWeb) {
      debugPrint('Web平台不支持振动，跳过');
      return;
    }

    try {
      // 使用两次振动模拟休息结束
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      debugPrint('触发休息结束振动');
    } catch (e) {
      debugPrint('触发休息结束振动失败: $e');
    }
  }

  // 取消振动 (HapticFeedback没有取消方法，此方法保留API兼容性)
  Future<void> cancel() async {
    // 在HapticFeedback中不需要执行任何操作
    debugPrint('HapticFeedback没有取消方法');
    return;
  }
}
