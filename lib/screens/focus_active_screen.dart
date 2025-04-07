import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/pomodoro_timer.dart';
import '../utils/time_formatter.dart';
import '../widgets/animated_app_bar.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/no_task_info.dart';
import '../widgets/focus_info_card.dart';
import '../widgets/focus_action_buttons.dart';
import '../global/app_global.dart';

// 自定义意图类，用于快捷键
class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class StopIntent extends Intent {
  const StopIntent();
}

class FocusActiveScreen extends StatefulWidget {
  const FocusActiveScreen({super.key});

  @override
  State<FocusActiveScreen> createState() => _FocusActiveScreenState();
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

    // 检测屏幕方向
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // 检测是否是桌面平台
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

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

    // 计算计时器尺寸
    final timerSize =
        isLandscape
            ? MediaQuery.of(context).size.height * 0.6
            : MediaQuery.of(context).size.width * 0.8;

    // 构建计时器部分
    Widget timerSection = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        vertical: isLandscape ? 16 : 24,
        horizontal: isLandscape ? 24 : 0,
      ),
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
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.15),
        size: timerSize,
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
    );

    // 构建任务信息部分
    Widget taskSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // 当前任务
        if (currentTask != null) ...[
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 20, color: stateColor),
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
          TaskCard(task: currentTask, stateColor: stateColor),
        ] else ...[
          Row(
            children: [
              Icon(Icons.assignment_late_outlined, size: 20, color: stateColor),
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
          NoTaskInfo(stateColor: stateColor),
        ],

        // 添加专注信息部分
        const SizedBox(height: 32),

        // 专注信息
        Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: stateColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '专注信息',
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
        const SizedBox(height: 12),
        FocusInfoCard(
          pomodoroProvider: pomodoroProvider,
          stateColor: stateColor,
        ),

        // 底部操作按钮
        const SizedBox(height: 32),
        FocusActionButtons(
          pomodoroProvider: pomodoroProvider,
          stateColor: stateColor,
          showFinishEarlyDialog: _showFinishEarlyDialog,
          showAbandonDialog: _showAbandonDialog,
          showChangeStateConfirmDialog: _showChangeStateConfirmDialog,
        ),
      ],
    );

    // 添加快捷键支持
    if (isDesktop) {
      return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.space): const PlayPauseIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): const StopIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            PlayPauseIntent: CallbackAction<PlayPauseIntent>(
              onInvoke: (PlayPauseIntent intent) {
                if (state == PomodoroState.paused) {
                  pomodoroProvider.resume();
                } else if (state != PomodoroState.paused && isRunning) {
                  pomodoroProvider.pause();
                }
                return null;
              },
            ),
            StopIntent: CallbackAction<StopIntent>(
              onInvoke: (StopIntent intent) {
                _showStopConfirmationDialog(context, pomodoroProvider);
                return null;
              },
            ),
          },
          child: _buildMainScaffold(
            context,
            stateText,
            stateColor,
            beginColor,
            isLandscape,
            timerSection,
            taskSection,
          ),
        ),
      );
    } else {
      return _buildMainScaffold(
        context,
        stateText,
        stateColor,
        beginColor,
        isLandscape,
        timerSection,
        taskSection,
      );
    }
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

  // 构建主界面Scaffold
  Widget _buildMainScaffold(
    BuildContext context,
    String stateText,
    Color stateColor,
    Color beginColor,
    bool isLandscape,
    Widget timerSection,
    Widget taskSection,
  ) {
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
      // 使用可滚动视图包装整个内容
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
          child:
              isLandscape
                  // 横屏布局
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // 改为顶部对齐
                    children: [
                      // 左侧计时器部分
                      Expanded(flex: 5, child: Center(child: timerSection)),

                      // 右侧信息部分
                      Expanded(
                        flex: 7,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(0, 20, 20, 24),
                          child: taskSection,
                        ),
                      ),
                    ],
                  )
                  // 竖屏布局，确保使用SingleChildScrollView
                  : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // 添加此行，确保列高度不会溢出
                        mainAxisSize: MainAxisSize.min,
                        children: [timerSection, taskSection],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  // 测试通知
  Future<void> _testNotification(BuildContext context) async {
    // 使用AppGlobal获取通知服务
    final notificationService = AppGlobal.getNotificationService(context);

    // 显示加载状态
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在发送测试通知...'),
        duration: Duration(seconds: 1),
      ),
    );

    // 发送测试通知
    await notificationService.showNotification(
      id: 999,
      title: '测试通知',
      body: '如果您看到这个通知，说明通知功能正常工作！',
    );

    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('测试通知已发送'), backgroundColor: Colors.green),
    );
  }
}
