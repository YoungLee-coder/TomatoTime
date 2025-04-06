import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 更新检查服务
class UpdateService {
  /// GitHub仓库API地址
  static const String _apiUrl =
      'https://api.github.com/repos/YoungLee-coder/TomatoTime/releases';

  /// 备用API地址 - 实际项目中可使用自己的服务器
  static const String _backupApiUrl =
      'https://gitee.com/api/v5/repos/YoungLee-coder/TomatoTime/releases';

  /// 当前应用版本 (不含前缀)
  static const String _currentVersion = '1.2';

  /// 当前应用版本显示
  static const String currentVersion = 'v1.2';

  /// 仓库发布页面URL
  static const String repoReleasesUrl =
      'https://github.com/YoungLee-coder/TomatoTime/releases';

  /// 备用仓库页面
  static const String backupRepoUrl =
      'https://gitee.com/YoungLee-coder/TomatoTime/releases';

  /// 检查更新
  Future<UpdateInfo> checkForUpdates() async {
    // 首先尝试GitHub API
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(
            const Duration(seconds: 15), // 增加超时时间
            onTimeout: () {
              throw Exception('请求超时');
            },
          );

      if (response.statusCode == 200) {
        return _parseReleaseInfo(response.body);
      }

      // 如果GitHub API失败，记录错误但不立即抛出
      debugPrint('GitHub API返回错误：${response.statusCode}，尝试备用API');
    } catch (e) {
      // 记录GitHub API错误但继续尝试备用API
      debugPrint('GitHub API请求失败: $e，尝试备用API');
    }

    // 尝试备用API
    try {
      final response = await http
          .get(Uri.parse(_backupApiUrl))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('备用API请求超时');
            },
          );

      if (response.statusCode == 200) {
        return _parseReleaseInfo(response.body, isBackup: true);
      }

      throw Exception('备用API返回错误：${response.statusCode}');
    } catch (e) {
      debugPrint('检查更新失败: $e');
      return UpdateInfo(
        hasUpdate: false,
        message: '检查更新失败，请检查网络连接或稍后再试',
        latestVersion: currentVersion,
        releaseUrl: repoReleasesUrl,
        error: true,
      );
    }
  }

  /// 解析发布信息
  UpdateInfo _parseReleaseInfo(String responseBody, {bool isBackup = false}) {
    try {
      final List<dynamic> releases = jsonDecode(responseBody);

      // 如果没有任何发布版本
      if (releases.isEmpty) {
        return UpdateInfo(
          hasUpdate: false,
          message: '当前已是最新版本',
          latestVersion: currentVersion,
          releaseUrl: isBackup ? backupRepoUrl : repoReleasesUrl,
        );
      }

      // 获取最新发布
      final latestRelease = releases.first;
      final String? tagName = latestRelease['tag_name'];

      if (tagName == null) {
        throw Exception('无法获取最新版本标签');
      }

      // 解析版本号 - 支持多种格式
      final String latestVersionDisplay = tagName;
      final String latestVersionClean = _cleanVersionNumber(tagName);
      final String currentVersionClean = _currentVersion;

      // 比较版本号
      final bool hasUpdate =
          _compareVersions(latestVersionClean, currentVersionClean) > 0;

      return UpdateInfo(
        hasUpdate: hasUpdate,
        message: hasUpdate ? '发现新版本：$latestVersionDisplay' : '当前已是最新版本',
        latestVersion: latestVersionDisplay,
        releaseUrl:
            latestRelease['html_url'] ??
            (isBackup ? backupRepoUrl : repoReleasesUrl),
        releaseNotes: latestRelease['body'] ?? '暂无更新说明',
      );
    } catch (e) {
      debugPrint('解析发布信息失败: $e');
      throw Exception('解析发布信息失败: $e');
    }
  }

  /// 清理版本号，移除所有非数字和点的前缀
  /// 如 "v1.2.3", "Release-1.2.3", "version-1.2" 等都会被转换为 "1.2.3"
  String _cleanVersionNumber(String version) {
    // 使用正则表达式查找第一个数字，并从那里开始截取
    final match = RegExp(r'(\d+(\.\d+)*)').firstMatch(version);
    if (match != null) {
      return match.group(1) ?? version;
    }
    return version;
  }

  /// 比较版本号
  /// 如果v1 > v2返回1，如果v1 < v2返回-1，如果相等返回0
  int _compareVersions(String v1, String v2) {
    // 如果版本号完全相同，直接返回0
    if (v1 == v2) return 0;

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
