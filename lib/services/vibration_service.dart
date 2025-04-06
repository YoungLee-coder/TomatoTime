import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// 振动服务类，负责管理应用内的振动功能
class VibrationService {
  // 检查设备是否支持振动
  Future<bool> hasVibrator() async {
    // Web平台不支持振动
    if (kIsWeb) {
      debugPrint('Web平台不支持振动');
      return false;
    }

    try {
      final hasVibratorDevice = await Vibration.hasVibrator() ?? false;
      debugPrint('设备${hasVibratorDevice ? "支持" : "不支持"}振动');
      return hasVibratorDevice;
    } catch (e) {
      debugPrint('检查振动器失败: $e');
      return false;
    }
  }

  // 触发简单振动
  Future<void> vibrate() async {
    // Web平台不支持振动
    if (kIsWeb) {
      debugPrint('Web平台不支持振动，跳过');
      return;
    }

    try {
      final hasVibratorDevice = await hasVibrator();
      if (!hasVibratorDevice) {
        debugPrint('设备不支持振动，跳过');
        return;
      }

      // 简单振动500毫秒
      await Vibration.vibrate(duration: 500);
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
      final hasVibratorDevice = await hasVibrator();
      if (!hasVibratorDevice) {
        debugPrint('设备不支持振动，跳过');
        return;
      }

      // 使用特定模式振动，表示专注结束
      // 参数含义: 等待时间(毫秒), 振动时间(毫秒), 等待时间, 振动时间...
      final pattern = [0, 300, 100, 300, 100, 300];
      await Vibration.vibrate(pattern: pattern);
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
      final hasVibratorDevice = await hasVibrator();
      if (!hasVibratorDevice) {
        debugPrint('设备不支持振动，跳过');
        return;
      }

      // 使用特定模式振动，表示休息结束
      final pattern = [0, 200, 100, 200];
      await Vibration.vibrate(pattern: pattern);
      debugPrint('触发休息结束振动');
    } catch (e) {
      debugPrint('触发休息结束振动失败: $e');
    }
  }

  // 取消振动
  Future<void> cancel() async {
    // Web平台不支持振动
    if (kIsWeb) {
      debugPrint('Web平台不支持振动，跳过');
      return;
    }

    try {
      await Vibration.cancel();
      debugPrint('取消振动');
    } catch (e) {
      debugPrint('取消振动失败: $e');
    }
  }
}
