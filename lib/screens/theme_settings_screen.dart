import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;
    final AppThemeMode currentThemeMode = settings.themeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('深色模式'), elevation: 0),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '主题模式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeModeOption(
                      context,
                      '跟随系统',
                      '自动根据系统设置切换深色和浅色模式',
                      AppThemeMode.system,
                      currentThemeMode,
                      settingsProvider,
                    ),
                    const Divider(),
                    _buildThemeModeOption(
                      context,
                      '浅色模式',
                      '始终使用浅色主题',
                      AppThemeMode.light,
                      currentThemeMode,
                      settingsProvider,
                    ),
                    const Divider(),
                    _buildThemeModeOption(
                      context,
                      '深色模式',
                      '始终使用深色主题',
                      AppThemeMode.dark,
                      currentThemeMode,
                      settingsProvider,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '关于深色模式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '深色模式可以减轻眼睛疲劳，特别是在低光环境下使用应用时。此外，对于使用OLED屏幕的设备，深色模式还可以节省电量。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    String title,
    String subtitle,
    AppThemeMode mode,
    AppThemeMode currentMode,
    SettingsProvider settingsProvider,
  ) {
    return InkWell(
      onTap: () {
        settingsProvider.updateThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            _getThemeModeIcon(mode),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Radio<AppThemeMode>(
              value: mode,
              groupValue: currentMode,
              onChanged: (AppThemeMode? value) {
                if (value != null) {
                  settingsProvider.updateThemeMode(value);
                }
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  // 获取主题模式图标
  Widget _getThemeModeIcon(AppThemeMode mode) {
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, size: 20),
    );
  }
}
