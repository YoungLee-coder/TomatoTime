import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/task_card.dart';
import 'focus_settings_screen.dart';
import 'focus_active_screen.dart';
import '../models/task.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 定义在State类中，保持状态
  bool _isTaskListExpanded = false;

  @override
  Widget build(BuildContext context) {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final todayTasks = taskProvider.todayTasks;
    final currentTask = pomodoroProvider.currentTask;
    final isRunning = pomodoroProvider.isRunning;
    final state = pomodoroProvider.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('番茄时间'),
        elevation: 0,
        actions: [
          // 专注设置按钮
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.timer_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FocusSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 番茄钟状态和任务
              _buildPomodoroStatus(context, pomodoroProvider),

              const SizedBox(height: 24),

              // 今日进度
              _buildTodayProgress(context, todayTasks),

              const SizedBox(height: 16),

              // 今日任务列表
              _buildTodayTasks(context, todayTasks, pomodoroProvider),
            ],
          ),
        ),
      ),
      floatingActionButton:
          isRunning
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FocusActiveScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.timer),
                label: const Text('正在专注'),
                backgroundColor:
                    state == PomodoroState.focusing
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
              )
              : null,
    );
  }

  Widget _buildPomodoroStatus(
    BuildContext context,
    PomodoroProvider pomodoroProvider,
  ) {
    final state = pomodoroProvider.state;
    final currentTask = pomodoroProvider.currentTask;
    final isRunning = pomodoroProvider.isRunning;
    final progress = pomodoroProvider.progress;
    final timeRemaining = pomodoroProvider.timeRemaining;

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态指示
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: stateColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  stateText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                  ),
                ),
                const Spacer(),
                if (isRunning)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FocusActiveScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('查看详情'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 当前任务（如果有）
            if (currentTask != null) ...[
              const Text(
                '当前任务',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                currentTask.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 16),
            ],

            // 番茄钟进度
            if (isRunning) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state == PomodoroState.focusing
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(timeRemaining),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 没有正在运行的番茄钟时，显示开始按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // 检查是否有已暂停的番茄钟，如果有则恢复它
                    if (pomodoroProvider.state == PomodoroState.paused) {
                      // 恢复已暂停的番茄钟
                      pomodoroProvider.resume();
                    } else {
                      // 没有暂停的番茄钟，按原来的逻辑启动新的番茄钟
                      final settingsProvider = Provider.of<SettingsProvider>(
                        context,
                        listen: false,
                      );

                      // 设置当前任务为null（不选择任务）
                      pomodoroProvider.setCurrentTask(null);

                      // 使用当前设置
                      pomodoroProvider.setSettings(settingsProvider.settings);

                      // 开始专注
                      pomodoroProvider.startFocus();
                    }

                    // 导航到专注活动页面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FocusActiveScreen(),
                      ),
                    );
                  },
                  icon:
                      pomodoroProvider.state == PomodoroState.paused
                          ? const Icon(Icons.play_arrow_rounded)
                          : const Icon(Icons.play_arrow_rounded),
                  label:
                      pomodoroProvider.state == PomodoroState.paused
                          ? const Text('恢复专注')
                          : const Text('开始专注'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgress(BuildContext context, List<Task> todayTasks) {
    // 计算今日任务完成进度
    final totalTasks = todayTasks.length;
    final completedTasks = todayTasks.where((task) => task.isCompleted).length;
    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日进度',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completionRate,
                      minHeight: 8,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completedTasks/$totalTasks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '完成率: ${(completionRate * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasks(
    BuildContext context,
    List<Task> todayTasks,
    PomodoroProvider pomodoroProvider,
  ) {
    if (todayTasks.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.task_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  '今天没有任务',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  '点击下方的"任务"标签添加任务',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 对任务进行排序：未完成的排在前面
    final sortedTasks = List<Task>.from(todayTasks);
    sortedTasks.sort((a, b) {
      // 优先排序条件：未完成的排在前面
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;

      // 如果完成状态相同，可以添加次要排序条件，例如按创建时间或名称
      return a.title.compareTo(b.title);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Text(
                '今日待办',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (sortedTasks.isNotEmpty)
                Text(
                  '未完成: ${sortedTasks.where((task) => !task.isCompleted).length}/${sortedTasks.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        ...sortedTasks.take(_isTaskListExpanded ? sortedTasks.length : 3).map((
          task,
        ) {
          return TaskCard(
            task: task,
            stateColor: Theme.of(context).colorScheme.primary,
            onTap: () {
              // 导航到任务详情页
              Navigator.pushNamed(context, '/task_detail', arguments: task);
            },
            onStartPomodoro: () {
              // 检查是否有已暂停的番茄钟
              if (pomodoroProvider.state == PomodoroState.paused) {
                // 恢复已暂停的番茄钟
                pomodoroProvider.resume();
              } else {
                // 设置当前任务并开始番茄钟
                pomodoroProvider.setCurrentTask(task);
                pomodoroProvider.startFocus();
              }

              // 导航到专注页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FocusActiveScreen(),
                ),
              );
            },
          );
        }).toList(),

        // 展开/收起按钮，只有任务超过3个时才显示
        if (sortedTasks.length > 3)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isTaskListExpanded = !_isTaskListExpanded;
              });
            },
            icon: Icon(
              _isTaskListExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 18,
            ),
            label: Text(
              _isTaskListExpanded ? '收起' : '查看更多 (${sortedTasks.length - 3})',
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  // 格式化时间（秒）为 mm:ss 格式
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
