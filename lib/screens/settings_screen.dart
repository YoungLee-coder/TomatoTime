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
import 'profile_edit_screen.dart';
import 'backup_restore_screen.dart';
import '../providers/task_provider.dart';
import '../providers/pomodoro_provider.dart';
import 'focus_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'theme_color_screen.dart';
import '../utils/theme.dart';

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
                      _buildNavigationSettingCardWithWidget(
                        context,
                        '深色模式',
                        _getThemeModeIcon(settings.themeMode),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ThemeSettingsScreen(),
                            ),
                          );
                        },
                        subtitle: _getThemeModeText(settings.themeMode),
                      ),
                      _buildNavigationSettingCardWithWidget(
                        context,
                        '主题颜色',
                        _buildThemeColorIcon(settings.themeColor),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ThemeColorScreen(),
                            ),
                          );
                        },
                        subtitle: _getThemeColorText(settings.themeColor),
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
                            applicationVersion: 'Release-1.1',
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
                      _buildNavigationSettingCard(
                        context,
                        '检查更新',
                        Icons.system_update_outlined,
                        _checkForUpdates,
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
                              '版本 Release-1.1',
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

  // 导航设置卡片 - 使用IconData
  Widget _buildNavigationSettingCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? subtitle,
  }) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
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

  // 导航设置卡片 - 使用自定义Widget图标
  Widget _buildNavigationSettingCardWithWidget(
    BuildContext context,
    String title,
    Widget iconWidget,
    VoidCallback onTap, {
    String? subtitle,
  }) {
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
              iconWidget,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
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

  // 获取主题模式图标
  Widget _getThemeModeIcon(AppThemeMode mode) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData iconData;

    switch (mode) {
      case AppThemeMode.system:
        iconData = Icons.brightness_auto;
        break;
      case AppThemeMode.light:
        iconData = Icons.brightness_7;
        break;
      case AppThemeMode.dark:
        iconData = Icons.brightness_4;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: colorScheme.primary, size: 20),
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
    final Color color = AppTheme.getPrimaryColor(themeColor);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.palette_outlined, color: color, size: 20),
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
    }
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

  // 检查更新
  void _checkForUpdates() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在检查更新...'),
              ],
            ),
          ),
    );

    try {
      // 初始化更新服务并检查更新
      final updateService = UpdateService();
      final updateInfo = await updateService.checkForUpdates();

      // 关闭加载对话框
      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框
      }

      if (!mounted) return;

      if (updateInfo.error) {
        // 显示错误消息
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(updateInfo.message),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 显示更新对话框
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(updateInfo.hasUpdate ? '发现新版本' : '检查更新'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(updateInfo.message),
                  if (updateInfo.hasUpdate &&
                      updateInfo.releaseNotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '更新内容:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        updateInfo.releaseNotes,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
                if (updateInfo.hasUpdate)
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      UrlService.openUrl(updateInfo.releaseUrl);
                    },
                    child: const Text('前往下载'),
                  ),
              ],
            ),
      );
    } catch (e) {
      // 关闭加载对话框
      if (mounted) {
        Navigator.pop(context);
      }

      // 显示错误消息
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('检查更新失败: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
