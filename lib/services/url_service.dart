import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// URL启动服务，用于打开外部链接
class UrlService {
  /// 打开URL
  static Future<bool> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      final bool canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        debugPrint('无法打开URL: $url');
        return false;
      }

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('打开URL失败: $e');
      return false;
    }
  }
}
