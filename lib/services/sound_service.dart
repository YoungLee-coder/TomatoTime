import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// 声音服务类，负责管理应用内的音频播放
class SoundService {
  // 音频播放器实例
  AudioPlayer? _audioPlayer;

  // 初始化音频播放器
  Future<void> init() async {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
      debugPrint('声音服务初始化成功');
    }
  }

  // 播放完成提示音
  Future<void> playCompletionSound() async {
    // 检查是否为Web平台，Web平台可能有限制
    if (kIsWeb) {
      debugPrint('Web平台不支持声音播放，跳过');
      return;
    }

    try {
      // 确保音频播放器已初始化
      if (_audioPlayer == null) {
        await init();
      }

      // 使用项目内的声音文件
      // 需确保在pubspec.yaml中正确配置assets
      await _audioPlayer!.setAsset('assets/sounds/completion_sound.mp3');
      await _audioPlayer!.play();

      debugPrint('播放完成提示音');
    } catch (e) {
      debugPrint('播放完成提示音失败: $e');
    }
  }

  // 播放开始提示音
  Future<void> playStartSound() async {
    // 检查是否为Web平台
    if (kIsWeb) {
      debugPrint('Web平台不支持声音播放，跳过');
      return;
    }

    try {
      // 确保音频播放器已初始化
      if (_audioPlayer == null) {
        await init();
      }

      // 使用项目内的声音文件
      await _audioPlayer!.setAsset('assets/sounds/start_sound.mp3');
      await _audioPlayer!.play();

      debugPrint('播放开始提示音');
    } catch (e) {
      debugPrint('播放开始提示音失败: $e');
    }
  }

  // 释放资源
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    debugPrint('声音服务已释放');
  }
}
