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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final sliderActiveColor =
        isDarkMode ? Colors.redAccent : colorScheme.primary;
    final valueColor = isDarkMode ? Colors.redAccent : colorScheme.primary;

    // 设置预设值
    List<int> presets = [];
    if (title == '专注时长') {
      presets = [15, 25, 30, 45, 60];
    } else if (title == '短休息时长') {
      presets = [3, 5, 7, 10];
    } else if (title == '长休息时长') {
      presets = [10, 15, 20, 30];
    } else if (title == '长休息间隔') {
      presets = [2, 3, 4, 5];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            InkWell(
              onTap: () {
                _showPresetsMenu(
                  context,
                  presets,
                  value,
                  onChanged,
                  suffix ?? ' 分钟',
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: valueColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value ${suffix ?? '分钟'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16, color: valueColor),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '$min',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: sliderActiveColor,
                  inactiveTrackColor: sliderActiveColor.withOpacity(0.15),
                  thumbColor: sliderActiveColor,
                  overlayColor: sliderActiveColor.withOpacity(0.2),
                  trackHeight: 4.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10.0,
                    elevation: 2.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20.0,
                  ),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: ((max - min) / step).round(),
                  label: value.toString(),
                  onChanged: (double newValue) {
                    // 确保值是step的倍数
                    final roundedValue = (newValue / step).round() * step;
                    onChanged(roundedValue);
                  },
                ),
              ),
            ),
            Text(
              '$max',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 显示预设值菜单
  void _showPresetsMenu(
    BuildContext context,
    List<int> presets,
    int currentValue,
    Function(int) onChanged,
    String unit,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDarkMode ? Colors.redAccent : colorScheme.primary;

    // 为了在弹出菜单底部添加自定义设置选项，复制一份列表
    final List<int> menuItems = List.from(presets);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('选择时间'),
            content: SizedBox(
              width: double.minPositive,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var preset in menuItems)
                    ListTile(
                      title: Text('$preset $unit'),
                      selected: preset == currentValue,
                      selectedTileColor: valueColor.withOpacity(0.1),
                      selectedColor: valueColor,
                      dense: true,
                      onTap: () {
                        onChanged(preset);
                        Navigator.of(context).pop();
                      },
                    ),
                  const Divider(),
                  ListTile(
                    title: const Text('使用滑块自定义'),
                    leading: const Icon(Icons.tune),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
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
}
