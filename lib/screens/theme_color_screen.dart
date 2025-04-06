import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings.dart';
import '../utils/theme.dart';

class ThemeColorScreen extends StatelessWidget {
  const ThemeColorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;
    final currentThemeColor = settings.themeColor;

    return Scaffold(
      appBar: AppBar(title: const Text('主题颜色'), elevation: 0),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '选择您喜欢的主题颜色，它将应用于整个应用程序的按钮、开关和其他元素。',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: AppThemeColor.values.length,
              itemBuilder: (context, index) {
                final themeColor = AppThemeColor.values[index];
                final isSelected = themeColor == currentThemeColor;
                return _buildColorItem(
                  context,
                  themeColor,
                  isSelected,
                  settingsProvider,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(
    BuildContext context,
    AppThemeColor themeColor,
    bool isSelected,
    SettingsProvider settingsProvider,
  ) {
    final Color color = AppTheme.getPrimaryColor(themeColor);
    final String colorName = _getColorName(themeColor);

    return InkWell(
      onTap: () {
        settingsProvider.updateThemeColor(themeColor);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(
                    color: Theme.of(context).colorScheme.onBackground,
                    width: 2,
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 32)
            else
              Icon(
                Icons.lens,
                color:
                    color.computeLuminance() > 0.5
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.3),
                size: 32,
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                colorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getColorName(AppThemeColor themeColor) {
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
}
