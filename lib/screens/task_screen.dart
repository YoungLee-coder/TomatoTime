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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });

    // 首次加载任务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadTasks();
      taskProvider.loadTodayTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text(
                '任务',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              floating: true,
              pinned: true,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              bottom: TabBar(
                controller: _tabController,
                tabs: const [Tab(text: '今日任务'), Tab(text: '所有任务')],
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [TodayTasksTab(), AllTasksTab()],
        ),
      ),
      floatingActionButton: _buildAddTaskButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 创建添加任务按钮
  Widget _buildAddTaskButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: FloatingActionButton.extended(
        onPressed: () => _createNewTask(context),
        icon: const Icon(Icons.add),
        label: const Text('新建任务'),
        tooltip: '创建新任务',
        backgroundColor:
            _currentIndex == 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // 创建新任务的方法
  Future<void> _createNewTask(BuildContext context) async {
    // 获取任务提供者
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // 导航到任务详情页面
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskDetailScreen(),
        fullscreenDialog: true,
      ),
    );

    // 无论结果如何，刷新任务列表
    await taskProvider.loadTasks();
    await taskProvider.loadTodayTasks();

    // 如果返回结果为true，说明成功创建了任务
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('任务创建成功'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(8),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
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
      return _buildEmptyState(context, '今天没有任务');
    }

    // 未完成任务
    final uncompletedTasks = tasks.where((task) => !task.isCompleted).toList();
    // 已完成任务
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await taskProvider.loadTodayTasks();
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AnimatedList(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        initialItemCount:
            (uncompletedTasks.isEmpty ? 0 : uncompletedTasks.length + 1) +
            (completedTasks.isEmpty ? 0 : completedTasks.length + 1),
        itemBuilder: (context, index, animation) {
          // 未完成任务部分
          if (uncompletedTasks.isNotEmpty) {
            if (index == 0) {
              return _buildSectionHeader(context, '进行中', animation);
            } else if (index <= uncompletedTasks.length) {
              return _buildTaskCardWithAnimation(
                context,
                uncompletedTasks[index - 1],
                taskProvider,
                animation,
              );
            }
            index -= (uncompletedTasks.length + 1);
          }

          // 已完成任务部分
          if (completedTasks.isNotEmpty) {
            if (index == 0) {
              return _buildSectionHeader(context, '已完成', animation);
            } else if (index <= completedTasks.length) {
              return _buildTaskCardWithAnimation(
                context,
                completedTasks[index - 1],
                taskProvider,
                animation,
              );
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                title == '进行中' ? Icons.access_time : Icons.check_circle,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCardWithAnimation(
    BuildContext context,
    task,
    TaskProvider taskProvider,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: _buildTaskCard(context, task, taskProvider),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.task_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角的"+"按钮添加新任务',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, task, TaskProvider taskProvider) {
    return TaskCard(
      task: task,
      stateColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
            fullscreenDialog: false,
          ),
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

        // 检查是否有番茄钟正在进行中
        if (pomodoroProvider.isRunning &&
            (pomodoroProvider.state == PomodoroState.focusing ||
                pomodoroProvider.state == PomodoroState.shortBreak ||
                pomodoroProvider.state == PomodoroState.longBreak)) {
          // 显示提示对话框
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('番茄钟正在进行中'),
                  content: const Text('当前已有一个番茄钟正在进行，请先完成或放弃当前番茄钟。'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // 跳转到正在进行中的番茄钟页面
                        Navigator.pushNamed(context, '/focus_active');
                      },
                      child: const Text('查看当前番茄钟'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
          );
          return;
        }

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8),
              behavior: SnackBarBehavior.floating,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('任务已删除'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(8),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('删除任务失败，请重试'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(8),
                        ),
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
      return _buildEmptyState(context, '没有任务');
    }

    // 未完成任务
    final uncompletedTasks = tasks.where((task) => !task.isCompleted).toList();
    // 已完成任务
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await taskProvider.loadTasks();
      },
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AnimatedList(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        initialItemCount:
            (uncompletedTasks.isEmpty ? 0 : uncompletedTasks.length + 1) +
            (completedTasks.isEmpty ? 0 : completedTasks.length + 1),
        itemBuilder: (context, index, animation) {
          // 未完成任务部分
          if (uncompletedTasks.isNotEmpty) {
            if (index == 0) {
              return _buildSectionHeader(context, '进行中', animation);
            } else if (index <= uncompletedTasks.length) {
              return _buildTaskCardWithAnimation(
                context,
                uncompletedTasks[index - 1],
                taskProvider,
                animation,
              );
            }
            index -= (uncompletedTasks.length + 1);
          }

          // 已完成任务部分
          if (completedTasks.isNotEmpty) {
            if (index == 0) {
              return _buildSectionHeader(context, '已完成', animation);
            } else if (index <= completedTasks.length) {
              return _buildTaskCardWithAnimation(
                context,
                completedTasks[index - 1],
                taskProvider,
                animation,
              );
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                title == '进行中' ? Icons.access_time : Icons.check_circle,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCardWithAnimation(
    BuildContext context,
    task,
    TaskProvider taskProvider,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: _buildTaskCard(context, task, taskProvider),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.task_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角的"+"按钮添加新任务',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, task, TaskProvider taskProvider) {
    return TaskCard(
      task: task,
      stateColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
            fullscreenDialog: false,
          ),
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

        // 检查是否有番茄钟正在进行中
        if (pomodoroProvider.isRunning &&
            (pomodoroProvider.state == PomodoroState.focusing ||
                pomodoroProvider.state == PomodoroState.shortBreak ||
                pomodoroProvider.state == PomodoroState.longBreak)) {
          // 显示提示对话框
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('番茄钟正在进行中'),
                  content: const Text('当前已有一个番茄钟正在进行，请先完成或放弃当前番茄钟。'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // 跳转到正在进行中的番茄钟页面
                        Navigator.pushNamed(context, '/focus_active');
                      },
                      child: const Text('查看当前番茄钟'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
          );
          return;
        }

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8),
              behavior: SnackBarBehavior.floating,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('任务已删除'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(8),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('删除任务失败，请重试'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(8),
                        ),
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
