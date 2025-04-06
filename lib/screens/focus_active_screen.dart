import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/settings_provider.dart';
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
  Color? _previousColor;

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

      // 检查是否需要保持屏幕常亮
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );
      if (settingsProvider.settings.keepScreenAwake) {
        try {
          // 使用WakelockPlus启用屏幕常亮
          WakelockPlus.enable();
          debugPrint('已启用屏幕常亮');
        } catch (e) {
          debugPrint('无法启用屏幕常亮: $e');
        }
      }
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
    // 释放屏幕常亮锁定
    try {
      // 使用WakelockPlus禁用屏幕常亮
      WakelockPlus.disable();
      debugPrint('已禁用屏幕常亮');
    } catch (e) {
      debugPrint('无法禁用屏幕常亮: $e');
    }
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
    IconData stateIcon;

    switch (state) {
      case PomodoroState.focusing:
        stateText = '专注中';
        stateColor = Theme.of(context).colorScheme.primary;
        stateIcon = Icons.timer;
        break;
      case PomodoroState.shortBreak:
        stateText = '短休息';
        stateColor = Theme.of(context).colorScheme.secondary;
        stateIcon = Icons.coffee;
        break;
      case PomodoroState.longBreak:
        stateText = '长休息';
        stateColor = Theme.of(context).colorScheme.tertiary;
        stateIcon = Icons.weekend;
        break;
      case PomodoroState.paused:
        stateText = '已暂停';
        stateColor = Colors.orange;
        stateIcon = Icons.pause_circle;
        break;
      default:
        stateText = '空闲';
        stateColor = Colors.grey;
        stateIcon = Icons.hourglass_empty;
    }

    // 保存当前颜色和之前颜色用于动画
    Color beginColor =
        _previousColor?.withOpacity(0.15) ?? stateColor.withOpacity(0.15);
    _previousColor = stateColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AnimatedAppBar(
        title: stateText,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: stateColor,
        titleSpacing: 8,
        leading: BackButton(color: stateColor),
      ),
      body: TweenAnimationBuilder<Color?>(
        tween: ColorTween(begin: beginColor, end: stateColor.withOpacity(0.15)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, color, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: color),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 计时器
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: stateColor.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: PomodoroTimer(
                      progress: progress,
                      timeRemaining: timeRemaining,
                      isRunning: state != PomodoroState.paused && isRunning,
                      progressColor: stateColor,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      size: MediaQuery.of(context).size.width * 0.8,
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
                  ),

                  const SizedBox(height: 16),

                  // 当前任务
                  if (currentTask != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 20,
                          color: stateColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '当前任务',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 任务卡片
                    Card(
                      elevation: 4,
                      shadowColor: stateColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: stateColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color:
                                        currentTask.isCompleted
                                            ? Colors.green
                                            : currentTask.color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (currentTask.isCompleted
                                                ? Colors.green
                                                : currentTask.color)
                                            .withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            if (currentTask.description.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                currentTask.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            const SizedBox(height: 16),

                            // 番茄钟进度
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: stateColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.timer_outlined,
                                    size: 14,
                                    color: stateColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '完成进度',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${currentTask.completedPomodoros}/${currentTask.estimatedPomodoros}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        currentTask.isCompleted
                                            ? Colors.green
                                            : stateColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // 进度条
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value:
                                    currentTask.estimatedPomodoros > 0
                                        ? currentTask.completedPomodoros /
                                            currentTask.estimatedPomodoros
                                        : 0,
                                minHeight: 8,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  currentTask.isCompleted
                                      ? Colors.green
                                      : stateColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: 20,
                          color: stateColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '无关联任务',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shadowColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: stateColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: stateColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.timer_outlined,
                                color: stateColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '当前专注没有关联到任何任务，您可以专心集中精力完成自由创作',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // 专注信息
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: stateColor),
                      const SizedBox(width: 8),
                      Text(
                        '专注信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shadowColor: stateColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: stateColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
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
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.coffee,
                                  label: '短休息',
                                  value: TimeFormatter.formatMinutes(
                                    pomodoroProvider
                                        .settings
                                        .shortBreakDuration,
                                  ),
                                  color: stateColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
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
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.repeat,
                                  label: '长休息间隔',
                                  value:
                                      '${pomodoroProvider.settings.longBreakInterval} 个',
                                  color: stateColor,
                                ),
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
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
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
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        minimumSize: MaterialStateProperty.all(const Size(120, 40)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: MaterialStateProperty.all(2),
        animationDuration: const Duration(milliseconds: 500),
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
    final state = pomodoroProvider.state;
    final isBreakState =
        state == PomodoroState.shortBreak ||
        state == PomodoroState.longBreak ||
        (state == PomodoroState.paused &&
            (pomodoroProvider.previousActiveState == PomodoroState.shortBreak ||
                pomodoroProvider.previousActiveState ==
                    PomodoroState.longBreak));

    final title = isBreakState ? '提前结束休息' : '提前结束';
    final content = isBreakState ? '确定要提前结束当前休息吗？' : '确定要提前结束当前番茄钟吗？';

    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 关闭对话框
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  // 根据状态调用不同的方法
                  if (isBreakState) {
                    // 休息状态调用finishBreakEarly
                    await pomodoroProvider.finishBreakEarly(context);
                  } else {
                    // 专注状态调用finishEarly
                    await pomodoroProvider.finishEarly(context);
                  }

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
            _showChangeStateConfirmDialog(
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
            _showChangeStateConfirmDialog(
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
