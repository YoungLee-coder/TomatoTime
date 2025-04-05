import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import 'profile_edit_screen.dart';
import 'backup_restore_screen.dart';
import '../providers/task_provider.dart';
import '../providers/pomodoro_provider.dart';
import 'focus_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;
  final UserService _userService = UserService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProfile = await _userService.getUserProfile();
      setState(() {
        _userProfile = userProfile;
      });
    } catch (e) {
      debugPrint('加载用户资料失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editProfile() async {
    if (_userProfile == null) return;

    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(userProfile: _userProfile!),
      ),
    );

    if (updatedProfile != null) {
      setState(() {
        _userProfile = updatedProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('设置'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                color: colorScheme.surfaceVariant.withOpacity(0.1),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // 用户资料卡片
                    _buildProfileCard(),

                    _buildSettingsSection(context, '番茄设置', [
                      _buildNavigationSettingCard(
                        context,
                        '番茄钟设置',
                        Icons.timer_outlined,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FocusSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ]),

                    _buildSettingsSection(context, '外观', [
                      _buildSwitchSettingCard(
                        context,
                        '暗黑模式',
                        settings.darkMode,
                        (value) {
                          settingsProvider.updateSetting(darkMode: value);
                        },
                      ),
                    ]),

                    _buildSettingsSection(context, '数据', [
                      _buildNavigationSettingCard(
                        context,
                        '备份与恢复',
                        Icons.backup_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BackupRestoreScreen(),
                            ),
                          );
                        },
                      ),
                      _buildNavigationSettingCard(
                        context,
                        '重置应用数据',
                        Icons.restart_alt_rounded,
                        _confirmResetApp,
                      ),
                    ]),

                    _buildSettingsSection(context, '关于', [
                      _buildNavigationSettingCard(
                        context,
                        '关于番茄时间',
                        Icons.info_outline,
                        () {
                          showAboutDialog(
                            context: context,
                            applicationName: '番茄时间',
                            applicationVersion: '1.0.0',
                            applicationIcon: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 48,
                              height: 48,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.timer, size: 48);
                              },
                            ),
                            applicationLegalese: '© 2025 YoungLee 保留所有权利',
                            children: const [
                              SizedBox(height: 16),
                              Text('一款简单好用的番茄工作法应用，帮助您提高工作效率和专注力。'),
                            ],
                          );
                        },
                      ),
                    ]),

                    // 底部版权信息
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '版本 1.0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '©2025 YoungLee 保留所有权利',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }

  // 构建用户资料卡片
  Widget _buildProfileCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: _editProfile,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile?.name ?? '用户',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userProfile?.tagline ?? '专注达人',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建设置部分
  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // 开关设置卡片
  Widget _buildSwitchSettingCard(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  // 时长设置卡片
  Widget _buildDurationSettingCard(
    BuildContext context,
    String title,
    int value,
    Function(int) onChanged, {
    int min = 1,
    int max = 60,
    String unit = '分钟',
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showPresetsMenu(context, presets, value, onChanged, unit);
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
                          '$value $unit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: valueColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                      divisions: max - min,
                      onChanged: (newValue) {
                        onChanged(newValue.round());
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
        ),
      ),
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

  // 导航设置卡片
  Widget _buildNavigationSettingCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16)),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (_userProfile?.avatarPath != null && !kIsWeb) {
      try {
        return CircleAvatar(
          radius: 30,
          backgroundImage: FileImage(File(_userProfile!.avatarPath!)),
        );
      } catch (e) {
        debugPrint('加载头像失败: $e');
      }
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 30,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // 确认重置应用
  void _confirmResetApp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('重置应用数据'),
            content: const Text('确定要重置所有应用数据吗？这将清除所有任务、历史记录和统计数据，此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetAppData();
                },
                child: const Text('重置'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  // 执行重置应用数据
  Future<void> _resetAppData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 重置任务数据
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final taskSuccess = await taskProvider.resetAllTasks();

      // 重置番茄钟历史记录
      final pomodoroProvider = Provider.of<PomodoroProvider>(
        context,
        listen: false,
      );
      final pomodoroSuccess = await pomodoroProvider.resetAllHistory();

      // 判断重置结果
      if (taskSuccess && pomodoroSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('应用数据已重置')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('部分数据重置失败，请重试')));
      }
    } catch (e) {
      debugPrint('重置应用数据错误: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('重置应用数据时发生错误')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
