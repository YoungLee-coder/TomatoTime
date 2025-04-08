import 'package:flutter/material.dart';
import '../providers/pomodoro_provider.dart';
import '../utils/time_formatter.dart';

/// 专注信息卡片组件
/// 显示专注相关的时间设置信息
class FocusInfoCard extends StatelessWidget {
  final PomodoroProvider pomodoroProvider;
  final Color stateColor;

  const FocusInfoCard({
    super.key,
    required this.pomodoroProvider,
    required this.stateColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: stateColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: stateColor.withOpacity(0.1), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!.withOpacity(0.8)
                  : Colors.white.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 第一行信息（专注时长和短休息）
            Row(
              children: [
                Flexible(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.timer,
                    label: '专注时长',
                    value: TimeFormatter.formatMinutes(
                      pomodoroProvider.settings.focusDuration,
                    ),
                    color: stateColor,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.coffee,
                    label: '短休息',
                    value: TimeFormatter.formatMinutes(
                      pomodoroProvider.settings.shortBreakDuration,
                    ),
                    color: stateColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第二行信息（长休息和长休息间隔）
            Row(
              children: [
                Flexible(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.weekend,
                    label: '长休息',
                    value: TimeFormatter.formatMinutes(
                      pomodoroProvider.settings.longBreakDuration,
                    ),
                    color: stateColor,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.repeat,
                    label: '长休息间隔',
                    value: '${pomodoroProvider.settings.longBreakInterval} 个',
                    color: stateColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? color.withOpacity(0.15)
                : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
