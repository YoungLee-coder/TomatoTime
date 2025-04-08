import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/update_service.dart';
import '../services/url_service.dart';
import '../widgets/settings_title.dart';
import '../widgets/settings_option.dart';
import '../widgets/settings_group.dart';
import 'profile_edit_screen.dart';
import 'backup_restore_screen.dart';
import '../providers/task_provider.dart';
import '../providers/pomodoro_provider.dart';
import 'focus_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'theme_color_screen.dart';
import '../utils/theme.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                color: colorScheme.surfaceVariant.withOpacity(0.05),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // 用户资料卡片
                    _buildProfileCard(),

                    // 番茄钟设置
                    SettingsGroup(
                      title: '番茄设置',
                      icon: Icons.timer_outlined,
                      children: [
                        SettingsOption(
                          icon: Icons.timer_outlined,
                          title: '番茄钟设置',
                          subtitle: '设置专注时长、休息时长及其他番茄钟参数',
                          type: SettingsOptionType.submenu,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const FocusSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // 外观设置
                    SettingsGroup(
                      title: '外观',
                      icon: Icons.palette_outlined,
                      children: [
                        SettingsOption(
                          icon: Icons.dark_mode_outlined,
                          title: '深色模式',
                          subtitle: _getThemeModeText(settings.themeMode),
                          type: SettingsOptionType.submenu,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ThemeSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsOption(
                          icon: Icons.color_lens_outlined,
                          title: '主题颜色',
                          subtitle: _getThemeColorText(settings.themeColor),
                          type: SettingsOptionType.color,
                          color: AppTheme.getPrimaryColor(settings.themeColor),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ThemeColorScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // 数据管理
                    SettingsGroup(
                      title: '数据',
                      icon: Icons.storage_outlined,
                      children: [
                        SettingsOption(
                          icon: Icons.backup_rounded,
                          title: '备份与恢复',
                          subtitle: '备份或恢复您的番茄钟数据和设置',
                          type: SettingsOptionType.submenu,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const BackupRestoreScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsOption(
                          icon: Icons.restart_alt_rounded,
                          title: '重置应用数据',
                          subtitle: '清除所有应用数据，将应用恢复到初始状态',
                          type: SettingsOptionType.normal,
                          isAccent: true,
                          onTap: _confirmResetApp,
                        ),
                      ],
                    ),

                    // 关于信息
                    SettingsGroup(
                      title: '关于',
                      icon: Icons.info_outline,
                      children: [
                        SettingsOption(
                          icon: Icons.info_outline,
                          title: '关于番茄时间',
                          subtitle: '了解应用的详细信息、开发者及版权声明',
                          type: SettingsOptionType.submenu,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsOption(
                          icon: Icons.system_update_outlined,
                          title: '检查更新',
                          subtitle: '检查是否有新版本可用',
                          type: SettingsOptionType.normal,
                          onTap: _checkForUpdates,
                        ),
                      ],
                    ),

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
                              '版本 v1.5',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '©2025 YoungLee 保留所有权利',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userProfile?.tagline ?? '专注达人',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
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

  // 获取主题模式图标
  Widget _getThemeModeIcon(AppThemeMode mode) {
    IconData icon;
    switch (mode) {
      case AppThemeMode.system:
        icon = Icons.brightness_auto;
        break;
      case AppThemeMode.light:
        icon = Icons.brightness_7;
        break;
      case AppThemeMode.dark:
        icon = Icons.brightness_2;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
    );
  }

  // 获取主题模式文本
  String _getThemeModeText(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  // 构建主题颜色图标
  Widget _buildThemeColorIcon(AppThemeColor themeColor) {
    final color = AppTheme.getPrimaryColor(themeColor);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  // 获取主题颜色文本
  String _getThemeColorText(AppThemeColor themeColor) {
    switch (themeColor) {
      case AppThemeColor.red:
        return '红色';
      case AppThemeColor.blue:
        return '蓝色';
      case AppThemeColor.green:
        return '绿色';
      case AppThemeColor.purple:
        return '紫色';
      case AppThemeColor.orange:
        return '橙色';
      case AppThemeColor.teal:
        return '蓝绿色';
      default:
        return '默认';
    }
  }

  // 确认重置应用数据
  void _confirmResetApp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('重置应用数据'),
            content: const Text('确定要重置所有应用数据吗？此操作不可恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetAppData();
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  // 重置应用数据
  Future<void> _resetAppData() async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final pomodoroProvider = Provider.of<PomodoroProvider>(
        context,
        listen: false,
      );
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );

      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 重置任务
      await taskProvider.resetAllTasks();

      // 重置番茄钟历史
      await pomodoroProvider.resetAllHistory();

      // 重置设置为默认值
      await settingsProvider.updateSettings(PomodoroSettings());

      // 重置用户资料
      await _userService.resetProfile();
      await _loadUserProfile();

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('应用数据已重置'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重置数据失败: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 检查更新
  Future<void> _checkForUpdates() async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('正在检查更新...'),
                ],
              ),
            ),
      );

      // 检查更新
      final updateService = UpdateService();
      final updateInfo = await updateService.checkForUpdates();

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 根据结果显示不同对话框
        if (updateInfo.hasUpdate) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('有新版本可用'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('最新版本: ${updateInfo.latestVersion}'),
                      const SizedBox(height: 12),
                      Text('当前版本: ${UpdateService.currentVersion}'),
                      const SizedBox(height: 16),
                      const Text('更新内容:'),
                      const SizedBox(height: 8),
                      Text(updateInfo.releaseNotes),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('稍后更新'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        UrlService.openUrl(updateInfo.releaseUrl);
                      },
                      child: const Text('立即更新'),
                    ),
                  ],
                ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('您已经在使用最新版本'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查更新失败: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
