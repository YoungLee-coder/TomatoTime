import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import 'focus_active_screen.dart';

class FocusSettingsScreen extends StatefulWidget {
  const FocusSettingsScreen({Key? key}) : super(key: key);

  @override
  State<FocusSettingsScreen> createState() => _FocusSettingsScreenState();
}

class _FocusSettingsScreenState extends State<FocusSettingsScreen> {
  int _focusDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _longBreakInterval = 4;
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  bool _keepScreenAwake = false;
  int? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 加载当前设置
  void _loadSettings() {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final settings = settingsProvider.settings;

    setState(() {
      _focusDuration = settings.focusDuration;
      _shortBreakDuration = settings.shortBreakDuration;
      _longBreakDuration = settings.longBreakDuration;
      _longBreakInterval = settings.longBreakInterval;
      _autoStartBreaks = settings.autoStartBreaks;
      _autoStartPomodoros = settings.autoStartPomodoros;
      _soundEnabled = settings.soundEnabled;
      _vibrationEnabled = settings.vibrationEnabled;
      _notificationsEnabled = settings.notificationsEnabled;
      _keepScreenAwake = settings.keepScreenAwake;
    });

    // 获取当前选中的任务（如果有）
    final pomodoroProvider = Provider.of<PomodoroProvider>(
      context,
      listen: false,
    );
    final currentTask = pomodoroProvider.currentTask;
    if (currentTask != null) {
      setState(() {
        _selectedTaskId = currentTask.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.todayTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('专注设置'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveSettings(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 时间设置
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '时间设置',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 专注时长
                  _buildDurationSetting(
                    context,
                    title: '专注时长',
                    value: _focusDuration,
                    min: 5,
                    max: 60,
                    step: 5,
                    onChanged: (value) {
                      setState(() {
                        _focusDuration = value;
                      });
                    },
                  ),

                  const Divider(),

                  // 短休息时长
                  _buildDurationSetting(
                    context,
                    title: '短休息时长',
                    value: _shortBreakDuration,
                    min: 1,
                    max: 30,
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        _shortBreakDuration = value;
                      });
                    },
                  ),

                  const Divider(),

                  // 长休息时长
                  _buildDurationSetting(
                    context,
                    title: '长休息时长',
                    value: _longBreakDuration,
                    min: 5,
                    max: 60,
                    step: 5,
                    onChanged: (value) {
                      setState(() {
                        _longBreakDuration = value;
                      });
                    },
                  ),

                  const Divider(),

                  // 长休息间隔
                  _buildDurationSetting(
                    context,
                    title: '长休息间隔',
                    value: _longBreakInterval,
                    min: 2,
                    max: 8,
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        _longBreakInterval = value;
                      });
                    },
                    suffix: '个番茄钟',
                  ),
                ],
              ),
            ),
          ),

          // 自动化设置
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '自动化设置',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 自动开始休息
                  SwitchListTile(
                    title: const Text('自动开始休息'),
                    subtitle: const Text('专注结束后自动开始休息'),
                    value: _autoStartBreaks,
                    onChanged: (value) {
                      setState(() {
                        _autoStartBreaks = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // 自动开始下一个番茄钟
                  SwitchListTile(
                    title: const Text('自动开始下一个番茄钟'),
                    subtitle: const Text('休息结束后自动开始下一个番茄钟'),
                    value: _autoStartPomodoros,
                    onChanged: (value) {
                      setState(() {
                        _autoStartPomodoros = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // 保持屏幕常亮
                  SwitchListTile(
                    title: const Text('保持屏幕常亮'),
                    subtitle: const Text('专注期间阻止屏幕自动关闭'),
                    value: _keepScreenAwake,
                    onChanged: (value) {
                      setState(() {
                        _keepScreenAwake = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          // 通知设置
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '通知设置',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 声音
                  SwitchListTile(
                    title: const Text('声音'),
                    subtitle: const Text('专注和休息结束时播放声音'),
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // 震动
                  SwitchListTile(
                    title: const Text('震动'),
                    subtitle: const Text('专注和休息结束时震动提醒'),
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // 通知
                  SwitchListTile(
                    title: const Text('通知'),
                    subtitle: const Text('显示系统通知提醒'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // 测试通知按钮
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('测试通知'),
                      onPressed:
                          _notificationsEnabled
                              ? () => _testNotification(context)
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 选择任务
          if (tasks.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择任务',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 任务列表
                    ...tasks.map((task) {
                      return RadioListTile<int?>(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration:
                                task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                            color:
                                task.isCompleted
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.6)
                                    : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        subtitle:
                            task.isCompleted
                                ? const Text(
                                  '已完成',
                                  style: TextStyle(color: Colors.green),
                                )
                                : Text(
                                  '${task.completedPomodoros}/${task.estimatedPomodoros} 番茄钟',
                                ),
                        value: task.id,
                        groupValue: _selectedTaskId,
                        onChanged:
                            task.isCompleted
                                ? null
                                : (value) {
                                  setState(() {
                                    _selectedTaskId = value;
                                  });
                                },
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),

                    // 无任务选项
                    RadioListTile<int?>(
                      title: const Text('不选择任务'),
                      value: null,
                      groupValue: _selectedTaskId,
                      onChanged: (value) {
                        setState(() {
                          _selectedTaskId = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建时长设置控件
  Widget _buildDurationSetting(
    BuildContext context, {
    required String title,
    required int value,
    required int min,
    required int max,
    required int step,
    required ValueChanged<int> onChanged,
    String? suffix,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueColor = colorScheme.primary;

    // 设置预设值 - 所有类型使用偶数个预设值，适合2列布局
    List<int> presets = [];
    if (title == '专注时长') {
      presets = [15, 25, 30, 45, 50, 60]; // 增加一个50分钟的选项
    } else if (title == '短休息时长') {
      presets = [3, 5, 7, 10]; // 保持4个选项
    } else if (title == '长休息时长') {
      presets = [10, 15, 20, 25, 30, 45]; // 增加25和45分钟选项
    } else if (title == '长休息间隔') {
      presets = [2, 3, 4, 6]; // 替换5为6，保持4个选项
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 使用LayoutBuilder检测可用空间，适应横屏
            LayoutBuilder(
              builder: (context, constraints) {
                // 检测当前设备方向
                bool isLandscape =
                    MediaQuery.of(context).orientation == Orientation.landscape;
                // 根据方向调整文字大小
                double titleSize = isLandscape ? 15.0 : 16.0;
                double valueSize = isLandscape ? 13.0 : 14.0;

                return Container(
                  height: 36, // 固定高度
                  child: Row(
                    // 在横屏模式下确保布局紧凑
                    mainAxisSize:
                        isLandscape ? MainAxisSize.min : MainAxisSize.max,
                    children: [
                      // 标题文本 - 使用Flexible防止溢出
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 当前值显示
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? 8 : 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: valueColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$value ${suffix ?? '分钟'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: valueSize,
                            color: valueColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // 使用GridView.builder以提供更灵活的网格布局
            LayoutBuilder(
              builder: (context, constraints) {
                // 检测是否为横屏模式
                bool isLandscape =
                    MediaQuery.of(context).orientation == Orientation.landscape;
                // 根据屏幕方向调整布局
                int crossAxisCount = isLandscape ? 3 : 2; // 横屏3列，竖屏2列
                double childAspectRatio = isLandscape ? 4.0 : 3.0; // 横屏时按钮更宽

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // 禁止滚动
                  shrinkWrap: true, // 自动调整高度
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 8, // 水平间距
                    mainAxisSpacing: 8, // 垂直间距
                  ),
                  itemCount: presets.length + 1, // 预设值数量 + 自定义按钮
                  itemBuilder: (context, index) {
                    // 最后一个是自定义按钮
                    if (index == presets.length) {
                      return _buildOptionButton(
                        text: '自定义',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isCustom: true,
                        onTap: () {
                          _showCustomValueDialog(
                            context,
                            min,
                            max,
                            step,
                            value,
                            onChanged,
                            suffix ?? '分钟',
                          );
                        },
                      );
                    }
                    // 预设值按钮
                    else {
                      final preset = presets[index];
                      final isSelected = value == preset;
                      return _buildOptionButton(
                        text: '$preset ${suffix ?? '分钟'}',
                        isSelected: isSelected,
                        colorScheme: colorScheme,
                        onTap: () => onChanged(preset),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 显示自定义值对话框
  void _showCustomValueDialog(
    BuildContext context,
    int min,
    int max,
    int step,
    int currentValue,
    ValueChanged<int> onChanged,
    String unit,
  ) {
    int inputValue = currentValue;
    final controller = TextEditingController(text: '$currentValue');
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                '输入自定义值',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '输入值',
                      suffixText: unit,
                      errorText:
                          inputValue < min || inputValue > max
                              ? '请输入${min}到${max}之间的值'
                              : null,
                    ),
                    onChanged: (value) {
                      try {
                        setState(() {
                          inputValue = int.parse(value);
                        });
                      } catch (_) {}
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消'),
                ),
                TextButton(
                  onPressed:
                      inputValue >= min && inputValue <= max
                          ? () {
                            onChanged(inputValue);
                            Navigator.pop(context);
                          }
                          : null,
                  child: Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 保存设置
  void _saveSettings(BuildContext context) {
    // 保存设置
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    settingsProvider.updateSetting(
      focusDuration: _focusDuration,
      shortBreakDuration: _shortBreakDuration,
      longBreakDuration: _longBreakDuration,
      longBreakInterval: _longBreakInterval,
      autoStartBreaks: _autoStartBreaks,
      autoStartPomodoros: _autoStartPomodoros,
      soundEnabled: _soundEnabled,
      vibrationEnabled: _vibrationEnabled,
      notificationsEnabled: _notificationsEnabled,
      keepScreenAwake: _keepScreenAwake,
    );

    // 设置当前任务
    final pomodoroProvider = Provider.of<PomodoroProvider>(
      context,
      listen: false,
    );
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (_selectedTaskId != null) {
      try {
        final selectedTask = taskProvider.tasks.firstWhere(
          (task) => task.id == _selectedTaskId,
        );
        pomodoroProvider.setCurrentTask(selectedTask);
      } catch (e) {
        pomodoroProvider.setCurrentTask(null);
      }
    } else {
      pomodoroProvider.setCurrentTask(null);
    }

    // 设置番茄钟设置
    pomodoroProvider.setSettings(settingsProvider.settings);
  }

  // 测试通知
  void _testNotification(BuildContext context) async {
    // 获取通知服务实例
    final notificationService =
        Provider.of<PomodoroProvider>(
          context,
          listen: false,
        ).notificationService;

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

  // 构建选项按钮
  Widget _buildOptionButton({
    required String text,
    required bool isSelected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
    bool isCustom = false,
  }) {
    // 检测当前设备方向
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // 横屏时适当调整文字大小
    double fontSize = isLandscape ? 13.0 : 14.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        // 调整内边距使文字在任何方向下都居中
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        alignment: Alignment.center, // 确保内容居中
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary
                  : isCustom
                  ? colorScheme.primaryContainer.withOpacity(0.5)
                  : colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected
                  ? null
                  : Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
        ),
        child:
            isCustom
                // 自定义按钮内容 - 使用FittedBox确保内容适应空间
                ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // 确保Row不会拉伸
                    children: [
                      Icon(
                        Icons.add,
                        size: fontSize + 2, // 图标稍大于文字
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )
                // 预设值按钮内容 - 使用FittedBox确保文字适应空间
                : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                    ),
                  ),
                ),
      ),
    );
  }
}
