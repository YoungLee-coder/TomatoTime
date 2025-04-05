import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '今日任务'), Tab(text: '所有任务')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [TodayTasksTab(), AllTasksTab()],
      ),
      floatingActionButton: _buildAddTaskButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 创建添加任务按钮
  Widget _buildAddTaskButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _createNewTask(context),
      icon: const Icon(Icons.add),
      label: const Text('新建任务'),
      tooltip: '创建新任务',
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // 创建新任务的方法
  Future<void> _createNewTask(BuildContext context) async {
    // 获取任务提供者
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // 导航到任务详情页面
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskDetailScreen()),
    );

    // 无论结果如何，刷新任务列表
    await taskProvider.loadTasks();
    await taskProvider.loadTodayTasks();

    // 如果返回结果为true，说明成功创建了任务
    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('任务创建成功'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class TodayTasksTab extends StatelessWidget {
  const TodayTasksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.todayTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '今天没有任务',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角的"+"按钮添加新任务',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    // 未完成任务
    final uncompletedTasks = tasks.where((task) => !task.isCompleted).toList();
    // 已完成任务
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // 未完成任务
        if (uncompletedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '进行中',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...uncompletedTasks
              .map((task) => _buildTaskCard(context, task, taskProvider))
              .toList(),
        ],

        // 已完成任务
        if (completedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '已完成',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...completedTasks
              .map((task) => _buildTaskCard(context, task, taskProvider))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, task, TaskProvider taskProvider) {
    return TaskCard(
      task: task,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        ).then((_) {
          // 刷新任务列表
          taskProvider.loadTasks();
          taskProvider.loadTodayTasks();
        });
      },
      onStartPomodoro: () {
        // 获取PomodoroProvider
        final pomodoroProvider = Provider.of<PomodoroProvider>(
          context,
          listen: false,
        );

        // 检查是否有已暂停的番茄钟
        if (pomodoroProvider.state == PomodoroState.paused) {
          // 恢复已暂停的番茄钟
          pomodoroProvider.resume();
        } else {
          // 设置当前任务
          pomodoroProvider.setCurrentTask(task);
          // 开始新的番茄钟
          pomodoroProvider.startFocus();
        }

        // 导航到专注页面
        Navigator.pushNamed(context, '/focus_active', arguments: task);
      },
      onToggleComplete: () async {
        // 切换任务完成状态
        final success = await taskProvider.toggleTaskCompletion(task);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(task.isCompleted ? '已标记为未完成' : '已标记为已完成'),
              backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      onDelete: () {
        _showDeleteConfirmation(context, task, taskProvider);
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    task,
    TaskProvider taskProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除任务"${task.title}"吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final success = await taskProvider.deleteTask(task.id!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (success) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('任务已删除')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('删除任务失败，请重试')),
                      );
                    }
                  }
                },
                child: const Text('删除'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}

class AllTasksTab extends StatelessWidget {
  const AllTasksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '没有任务',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角的"+"按钮添加新任务',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    // 未完成任务
    final uncompletedTasks = tasks.where((task) => !task.isCompleted).toList();
    // 已完成任务
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // 未完成任务
        if (uncompletedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '进行中',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...uncompletedTasks
              .map((task) => _buildTaskCard(context, task, taskProvider))
              .toList(),
        ],

        // 已完成任务
        if (completedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '已完成',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...completedTasks
              .map((task) => _buildTaskCard(context, task, taskProvider))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, task, TaskProvider taskProvider) {
    return TaskCard(
      task: task,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        ).then((_) {
          // 刷新任务列表
          taskProvider.loadTasks();
          taskProvider.loadTodayTasks();
        });
      },
      onStartPomodoro: () {
        // 获取PomodoroProvider
        final pomodoroProvider = Provider.of<PomodoroProvider>(
          context,
          listen: false,
        );

        // 检查是否有已暂停的番茄钟
        if (pomodoroProvider.state == PomodoroState.paused) {
          // 恢复已暂停的番茄钟
          pomodoroProvider.resume();
        } else {
          // 设置当前任务
          pomodoroProvider.setCurrentTask(task);
          // 开始新的番茄钟
          pomodoroProvider.startFocus();
        }

        // 导航到专注页面
        Navigator.pushNamed(context, '/focus_active', arguments: task);
      },
      onToggleComplete: () async {
        // 切换任务完成状态
        final success = await taskProvider.toggleTaskCompletion(task);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(task.isCompleted ? '已标记为未完成' : '已标记为已完成'),
              backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      onDelete: () {
        _showDeleteConfirmation(context, task, taskProvider);
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    task,
    TaskProvider taskProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除任务"${task.title}"吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final success = await taskProvider.deleteTask(task.id!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (success) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('任务已删除')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('删除任务失败，请重试')),
                      );
                    }
                  }
                },
                child: const Text('删除'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}
