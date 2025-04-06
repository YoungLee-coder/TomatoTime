import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../widgets/pomodoro_timer.dart';
import '../utils/time_formatter.dart';
import '../widgets/animated_app_bar.dart';
import '../providers/task_provider.dart';

class FocusActiveScreen extends StatefulWidget {
  const FocusActiveScreen({Key? key}) : super(key: key);

  @override
  _FocusActiveScreenState createState() => _FocusActiveScreenState();
}

class _FocusActiveScreenState extends State<FocusActiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.repeat(reverse: true);

    // 添加刷新任务的逻辑
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupTaskRefresh();

      // 设置返回首页的回调
      final pomodoroProvider = Provider.of<PomodoroProvider>(
        context,
        listen: false,
      );
      pomodoroProvider.setReturnToHomeCallback(() {
        if (mounted) {
          Navigator.of(context).pop(); // 返回上一页（首页）
        }
      });
    });
  }

  // 设置任务刷新机制
  void _setupTaskRefresh() {
    // 获取提供者
    final pomodoroProvider = Provider.of<PomodoroProvider>(
      context,
      listen: false,
    );
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // 立即检查是否需要刷新
    _checkForTaskRefresh();

    // 立即刷新一次任务列表，确保最新状态
    taskProvider.refreshTasks();

    // 监听任务提供者变化，当任务列表变化时强制刷新
    taskProvider.addListener(() {
      if (mounted) {
        setState(() {
          // 强制刷新界面以显示最新的任务状态
          debugPrint('任务列表已更新，强制刷新界面');
        });
      }
    });

    // 监听番茄钟提供者变化，当任务标志需要刷新时执行刷新
    pomodoroProvider.addListener(() {
      if (mounted && pomodoroProvider.needRefreshTasks) {
        debugPrint('监测到番茄钟提供者标志变化，立即刷新任务列表');
        pomodoroProvider.resetRefreshTasksFlag();
        taskProvider.refreshTasks();
      }
    });
  }

  // 检查是否需要刷新任务
  void _checkForTaskRefresh() {
    if (!mounted) return;

    final pomodoroProvider = Provider.of<PomodoroProvider>(
      context,
      listen: false,
    );
    if (pomodoroProvider.needRefreshTasks) {
      debugPrint('检测到需要刷新任务列表');

      // 重置标志
      pomodoroProvider.resetRefreshTasksFlag();

      // 刷新任务
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.refreshTasks();

      debugPrint('刷新任务列表完成');
    }

    // 更频繁地检查是否需要刷新（从2秒改为0.5秒）
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkForTaskRefresh();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context);
    final isRunning = pomodoroProvider.isRunning;
    final state = pomodoroProvider.state;
    final progress = pomodoroProvider.progress;
    final timeRemaining = pomodoroProvider.timeRemaining;
    final currentTask = pomodoroProvider.currentTask;

    String stateText;
    Color stateColor;

    switch (state) {
      case PomodoroState.focusing:
        stateText = '专注中';
        stateColor = Theme.of(context).colorScheme.primary;
        break;
      case PomodoroState.shortBreak:
        stateText = '短休息';
        stateColor = Theme.of(context).colorScheme.secondary;
        break;
      case PomodoroState.longBreak:
        stateText = '长休息';
        stateColor = Theme.of(context).colorScheme.secondary;
        break;
      case PomodoroState.paused:
        stateText = '已暂停';
        stateColor = Colors.orange;
        break;
      default:
        stateText = '空闲';
        stateColor = Colors.grey;
    }

    return Scaffold(
      appBar: AnimatedAppBar(
        title: stateText,
        elevation: 0,
        backgroundColor:
            state == PomodoroState.paused
                ? null // 暂停状态下使用默认背景色
                : state == PomodoroState.focusing
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : state == PomodoroState.shortBreak ||
                    state == PomodoroState.longBreak
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                : null,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              state == PomodoroState.paused
                  ? Theme.of(context)
                      .colorScheme
                      .background // 暂停状态下使用白色背景
                  : state == PomodoroState.focusing
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : state == PomodoroState.shortBreak ||
                      state == PomodoroState.longBreak
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 当前状态
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state == PomodoroState.focusing
                          ? Icons.timer
                          : state == PomodoroState.paused
                          ? Icons.pause
                          : Icons.coffee,
                      color: stateColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stateText,
                      style: TextStyle(
                        color: stateColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 计时器
              PomodoroTimer(
                progress: progress,
                timeRemaining: timeRemaining,
                isRunning: state != PomodoroState.paused && isRunning,
                progressColor:
                    state == PomodoroState.focusing
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                onStart:
                    state == PomodoroState.paused
                        ? () {
                          pomodoroProvider.resume();
                        }
                        : null,
                onPause:
                    state != PomodoroState.paused && isRunning
                        ? () {
                          pomodoroProvider.pause();
                        }
                        : null,
                onStop: () {
                  _showStopConfirmationDialog(context, pomodoroProvider);
                },
              ),

              const SizedBox(height: 32),

              // 当前任务
              if (currentTask != null) ...[
                const Text(
                  '当前任务',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color:
                                    currentTask.isCompleted
                                        ? Colors.green
                                        : currentTask.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentTask.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      currentTask.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        if (currentTask.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            currentTask.description,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 12),

                        // 番茄钟进度
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${currentTask.completedPomodoros}/${currentTask.estimatedPomodoros}',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value:
                                      currentTask.estimatedPomodoros > 0
                                          ? currentTask.completedPomodoros /
                                              currentTask.estimatedPomodoros
                                          : 0,
                                  minHeight: 6,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    currentTask.isCompleted
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  '无关联任务',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '当前专注没有关联到任何任务',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 专注信息
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(
                            context,
                            icon: Icons.timer,
                            label: '专注时长',
                            value: TimeFormatter.formatMinutes(
                              pomodoroProvider.settings.focusDuration,
                            ),
                          ),
                          _buildInfoItem(
                            context,
                            icon: Icons.coffee,
                            label: '短休息',
                            value: TimeFormatter.formatMinutes(
                              pomodoroProvider.settings.shortBreakDuration,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(
                            context,
                            icon: Icons.weekend,
                            label: '长休息',
                            value: TimeFormatter.formatMinutes(
                              pomodoroProvider.settings.longBreakDuration,
                            ),
                          ),
                          _buildInfoItem(
                            context,
                            icon: Icons.repeat,
                            label: '长休息间隔',
                            value:
                                '${pomodoroProvider.settings.longBreakInterval} 个',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 底部操作按钮
              _buildActions(context, pomodoroProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showStopConfirmationDialog(
    BuildContext context,
    PomodoroProvider pomodoroProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认停止'),
            content: const Text('确定要停止当前番茄钟吗？您的进度将不会被保存。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  pomodoroProvider.stop();
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  // 显示提前结束对话框
  void _showFinishEarlyDialog(
    BuildContext context,
    PomodoroProvider pomodoroProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('提前结束'),
            content: const Text('确定要提前结束当前番茄钟吗？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 关闭对话框
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  // 等待提前结束操作完成，传递context参数
                  await pomodoroProvider.finishEarly(context);

                  // 确保对话框上下文仍然有效
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(); // 关闭对话框
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  // 显示放弃番茄钟对话框
  void _showAbandonDialog(
    BuildContext context,
    PomodoroProvider pomodoroProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('放弃番茄钟'),
            content: const Text('确定要放弃当前番茄钟吗？放弃后本次专注将不会计入完成记录。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 关闭对话框
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  // 等待放弃番茄钟操作完成，传递context参数
                  await pomodoroProvider.abandonPomodoro(context);

                  // 确保对话框上下文仍然有效
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(); // 关闭对话框
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  // 构建底部操作按钮
  Widget _buildActions(
    BuildContext context,
    PomodoroProvider pomodoroProvider,
  ) {
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
            _showChangeStateConfirmDialog(
              context,
              pomodoroProvider,
              '开始短休息',
              '这将视为提前完成当前番茄钟，是否继续？',
              () async {
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
            _showChangeStateConfirmDialog(
              context,
              pomodoroProvider,
              '开始长休息',
              '这将视为提前完成当前番茄钟，是否继续？',
              () async {
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
            _showChangeStateConfirmDialog(
              context,
              pomodoroProvider,
              '开始专注',
              '这将提前结束休息直接进入下一个番茄钟，是否继续？',
              () => pomodoroProvider.startFocus(context),
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
            _showFinishEarlyDialog(context, pomodoroProvider);
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
            _showAbandonDialog(context, pomodoroProvider);
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
            _showFinishEarlyDialog(context, pomodoroProvider);
          },
        ),
      );
    }

    // 组织按钮为网格布局
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          // 第一行按钮 (最多2个)
          if (actionButtons.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  actionButtons.length == 1
                      ? [actionButtons[0]]
                      : [
                        actionButtons[0],
                        if (actionButtons.length > 1) actionButtons[1],
                      ],
            ),

          // 如果有更多按钮，添加第二行
          if (actionButtons.length > 2) ...[
            const SizedBox(height: 8), // 行间距
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  actionButtons.length == 3
                      ? [actionButtons[2]]
                      : [
                        actionButtons[2],
                        if (actionButtons.length > 3) actionButtons[3],
                      ],
            ),
          ],
        ],
      ),
    );
  }

  // 显示状态切换确认对话框
  void _showChangeStateConfirmDialog(
    BuildContext context,
    PomodoroProvider pomodoroProvider,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 关闭对话框
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 关闭对话框
                  onConfirm(); // 执行确认后的操作
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }
}
