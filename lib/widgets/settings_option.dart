import 'package:flutter/material.dart';

/// 设置选项类型
enum SettingsOptionType {
  /// 带图标的普通选项
  normal,

  /// 开关选项
  toggle,

  /// 色彩选项
  color,

  /// 子菜单选项
  submenu,

  /// 带文本值的选项
  text,
}

/// 设置选项组件
/// 统一设置界面的选项样式，支持多种选项类型
class SettingsOption extends StatelessWidget {
  /// 选项图标
  final IconData icon;

  /// 选项标题
  final String title;

  /// 选项说明
  final String? subtitle;

  /// 选项类型
  final SettingsOptionType type;

  /// 当选项被点击时的回调
  final VoidCallback? onTap;

  /// 开关状态值（对于toggle类型）
  final bool? value;

  /// 开关改变回调（对于toggle类型）
  final ValueChanged<bool>? onChanged;

  /// 颜色值（对于color类型）
  final Color? color;

  /// 文本值（对于text类型）
  final String? textValue;

  /// 选项是否为强调色调
  final bool isAccent;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.type,
    this.onTap,
    this.value,
    this.onChanged,
    this.color,
    this.textValue,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    // 确定选项颜色
    final themeColor =
        isAccent
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标区域
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: themeColor),
              ),
              const SizedBox(width: 16),

              // 标题和子标题区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 根据类型显示不同的尾部组件
              _buildTrailingWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建尾部组件
  Widget _buildTrailingWidget(BuildContext context) {
    switch (type) {
      case SettingsOptionType.toggle:
        return Switch(value: value ?? false, onChanged: onChanged);

      case SettingsOptionType.color:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color ?? Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
        );

      case SettingsOptionType.submenu:
        return const Icon(Icons.chevron_right, size: 20);

      case SettingsOptionType.text:
        return Text(
          textValue ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        );

      case SettingsOptionType.normal:
      default:
        return const SizedBox.shrink();
    }
  }
}
