import 'package:flutter/material.dart';

/// 设置分组组件
/// 用于将相关设置选项组织在一起，提供统一的样式和布局
class SettingsGroup extends StatelessWidget {
  /// 分组标题
  final String title;

  /// 分组图标
  final IconData icon;

  /// 分组颜色
  final Color? color;

  /// 子组件列表
  final List<Widget> children;

  /// 分组说明文本
  final String? description;

  const SettingsGroup({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    required this.children,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    // 确定分组颜色
    final themeColor = color ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题
          Row(
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

          // 分组说明
          if (description != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],

          // 设置选项
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
