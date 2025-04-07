import 'package:flutter/material.dart';
import '../providers/pomodoro_provider.dart';

/// 专注屏幕操作按钮组件
class FocusActionButtons extends StatelessWidget {
  final PomodoroProvider pomodoroProvider;
  final Color stateColor;
  final Function(BuildContext, PomodoroProvider) showFinishEarlyDialog;
  final Function(BuildContext, PomodoroProvider) showAbandonDialog;
  final Function(BuildContext, PomodoroProvider, String, String, VoidCallback)
  showChangeStateConfirmDialog;

  const FocusActionButtons({
    super.key,
    required this.pomodoroProvider,
    required this.stateColor,
    required this.showFinishEarlyDialog,
    required this.showAbandonDialog,
    required this.showChangeStateConfirmDialog,
  });

  @override
  Widget build(BuildContext context) {
    final state = pomodoroProvider.state;
    final List<Widget> actionButtons = [];

    // 根据状态添加不同按钮
    if (state == PomodoroState.focusing) {
      // 短休息按钮
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.coffee,
          label: '短休息',
          onPressed: () {
            showChangeStateConfirmDialog(
              context,
              pomodoroProvider,
              '开始短休息',
              '这将视为提前完成当前番茄钟，是否继续？',
              () async {
                // 设置手动状态切换标志
                pomodoroProvider.setManualStateChange(true);

                // 先提前完成当前番茄钟，确保统计正确记录
                await pomodoroProvider.finishEarly(context);

                // 如果上下文还有效，则开始短休息
                if (context.mounted) {
                  pomodoroProvider.startShortBreak(context);
                }
              },
            );
          },
        ),
      );

      // 长休息按钮
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.weekend,
          label: '长休息',
          onPressed: () {
            showChangeStateConfirmDialog(
              context,
              pomodoroProvider,
              '开始长休息',
              '这将视为提前完成当前番茄钟，是否继续？',
              () async {
                // 设置手动状态切换标志
                pomodoroProvider.setManualStateChange(true);

                // 先提前完成当前番茄钟，确保统计正确记录
                await pomodoroProvider.finishEarly(context);

                // 如果上下文还有效，则开始长休息
                if (context.mounted) {
                  pomodoroProvider.startLongBreak(context);
                }
              },
            );
          },
        ),
      );
    } else if (state == PomodoroState.shortBreak ||
        state == PomodoroState.longBreak) {
      // 专注按钮
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.timer,
          label: '专注',
          onPressed: () {
            showChangeStateConfirmDialog(
              context,
              pomodoroProvider,
              '开始专注',
              '这将提前结束休息直接进入下一个番茄钟，是否继续？',
              () async {
                // 设置手动状态切换标志
                pomodoroProvider.setManualStateChange(true);

                // 提前结束休息
                await pomodoroProvider.finishBreakEarly(context);

                // 如果上下文还有效，则开始专注
                if (context.mounted) {
                  pomodoroProvider.startFocus(context);
                }
              },
            );
          },
        ),
      );
    }

    // 仅在专注状态下显示提前结束和放弃番茄钟按钮
    if (state == PomodoroState.focusing ||
        (state == PomodoroState.paused &&
            pomodoroProvider.previousActiveState == PomodoroState.focusing)) {
      // 提前结束按钮
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.done_all,
          label: '提前结束',
          color: Theme.of(context).colorScheme.tertiary,
          onPressed: () {
            showFinishEarlyDialog(context, pomodoroProvider);
          },
        ),
      );

      // 放弃番茄钟按钮
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.cancel_outlined,
          label: '放弃番茄钟',
          color: Colors.red,
          onPressed: () {
            showAbandonDialog(context, pomodoroProvider);
          },
        ),
      );
    }
    // 仅在休息状态下显示提前结束按钮
    else if (state == PomodoroState.shortBreak ||
        state == PomodoroState.longBreak ||
        (state == PomodoroState.paused &&
            (pomodoroProvider.previousActiveState == PomodoroState.shortBreak ||
                pomodoroProvider.previousActiveState ==
                    PomodoroState.longBreak))) {
      // 提前结束按钮
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.done_all,
          label: '提前结束',
          color: Theme.of(context).colorScheme.tertiary,
          onPressed: () {
            showFinishEarlyDialog(context, pomodoroProvider);
          },
        ),
      );
    }

    // 组织按钮为网格布局
    return Padding(
      // 增加左右内边距，确保按钮不会太靠近屏幕边缘
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
      child: Column(
        children: [
          // 将按钮布局为两行，每行最多两个按钮
          if (actionButtons.isNotEmpty) ...[
            // 第一行按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (actionButtons.length > 0)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: actionButtons[0],
                    ),
                  ),
                if (actionButtons.length > 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: actionButtons[1],
                    ),
                  ),
              ],
            ),

            // 增加行之间的间距
            const SizedBox(height: 16.0),

            // 第二行按钮（如果有的话）
            if (actionButtons.length > 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (actionButtons.length > 2)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: actionButtons[2],
                      ),
                    ),
                  if (actionButtons.length > 3)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: actionButtons[3],
                      ),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 500),
        style: TextStyle(color: Colors.white),
        child: Icon(icon, size: 18),
      ),
      label: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 500),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        child: Text(label),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          return color ?? Theme.of(context).colorScheme.primary;
        }),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        minimumSize: MaterialStateProperty.all(const Size(0, 40)),
        maximumSize: MaterialStateProperty.all(const Size(double.infinity, 45)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: MaterialStateProperty.all(2),
        animationDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
