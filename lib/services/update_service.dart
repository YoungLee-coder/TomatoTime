import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 更新检查服务
class UpdateService {
  /// GitHub仓库API地址
  static const String _apiUrl =
      'https://api.github.com/repos/YoungLee-coder/TomatoTime/releases';

  /// 当前应用版本
  static const String currentVersion = 'Release-1.1';

  /// 仓库发布页面URL
  static const String repoReleasesUrl =
      'https://github.com/YoungLee-coder/TomatoTime/releases';

  /// 检查更新
  Future<UpdateInfo> checkForUpdates() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('请求超时');
            },
          );

      if (response.statusCode != 200) {
        throw Exception('服务器返回错误：${response.statusCode}');
      }

      final List<dynamic> releases = jsonDecode(response.body);

      // 如果没有任何发布版本
      if (releases.isEmpty) {
        return UpdateInfo(
          hasUpdate: false,
          message: '当前已是最新版本',
          latestVersion: currentVersion,
          releaseUrl: repoReleasesUrl,
        );
      }

      // 获取最新发布
      final latestRelease = releases.first;
      final String latestVersion = latestRelease['tag_name'] ?? 'unknown';

      // 移除"Release-"前缀（如果有）
      final String cleanLatestVersion = latestVersion.replaceAll(
        'Release-',
        '',
      );

      // 比较版本号
      final bool hasUpdate =
          _compareVersions(cleanLatestVersion, currentVersion) > 0;

      return UpdateInfo(
        hasUpdate: hasUpdate,
        message: hasUpdate ? '发现新版本：$cleanLatestVersion' : '当前已是最新版本',
        latestVersion: cleanLatestVersion,
        releaseUrl: latestRelease['html_url'] ?? repoReleasesUrl,
        releaseNotes: latestRelease['body'] ?? '暂无更新说明',
      );
    } catch (e) {
      debugPrint('检查更新失败: $e');
      return UpdateInfo(
        hasUpdate: false,
        message: '检查更新失败：$e',
        latestVersion: currentVersion,
        releaseUrl: repoReleasesUrl,
        error: true,
      );
    }
  }

  /// 比较版本号
  /// 如果v1 > v2返回1，如果v1 < v2返回-1，如果相等返回0
  int _compareVersions(String v1, String v2) {
    // 分割版本号为主要部分和次要部分
    final List<String> v1Parts = v1.split('.');
    final List<String> v2Parts = v2.split('.');

    // 补全短的版本号，使两个版本号有相同数量的部分
    final int maxLength =
        v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;

    for (int i = 0; i < maxLength; i++) {
      final int v1Part = i < v1Parts.length ? int.tryParse(v1Parts[i]) ?? 0 : 0;
      final int v2Part = i < v2Parts.length ? int.tryParse(v2Parts[i]) ?? 0 : 0;

      if (v1Part > v2Part) {
        return 1;
      } else if (v1Part < v2Part) {
        return -1;
      }
    }

    return 0;
  }
}

/// 更新信息类
class UpdateInfo {
  final bool hasUpdate;
  final String message;
  final String latestVersion;
  final String releaseUrl;
  final String releaseNotes;
  final bool error;

  UpdateInfo({
    required this.hasUpdate,
    required this.message,
    required this.latestVersion,
    required this.releaseUrl,
    this.releaseNotes = '',
    this.error = false,
  });
}
