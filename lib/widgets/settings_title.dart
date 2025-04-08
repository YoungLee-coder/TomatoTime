import 'package:flutter/material.dart';

/// 设置屏幕标题组件
/// 统一设置界面的标题样式，提供带图标和动画效果的标题
class SettingsTitle extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 标题图标
  final IconData icon;

  /// 主题色调
  final Color? color;

  /// 是否包含下边距
  final bool marginBottom;

  const SettingsTitle({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.marginBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(top: 16, bottom: marginBottom ? 12 : 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: themeColor),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
