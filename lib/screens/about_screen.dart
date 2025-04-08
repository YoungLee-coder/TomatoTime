import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/url_service.dart';
import '../widgets/animated_app_bar.dart';

/// 关于页面
/// 展示应用信息、开发者信息和版权说明
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AnimatedAppBar(
        title: '关于番茄时间',
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        titleSpacing: 8,
        leading: BackButton(color: Theme.of(context).colorScheme.primary),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 应用logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 应用名称
                Text(
                  '番茄时间',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                // 应用版本
                Text(
                  'v1.5.1',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),

                // 应用简介
                _buildSection(
                  context,
                  title: '应用简介',
                  content:
                      '番茄时间是一款专注于提高工作和学习效率的番茄钟应用，'
                      '结合了任务管理和时间统计功能，帮助您更有效地安排时间，减少拖延，提升专注力。',
                ),

                // 开发者信息
                _buildSection(
                  context,
                  title: '开发者信息',
                  content:
                      '由YoungLee开发，使用Flutter构建的跨平台应用，'
                      '支持Windows、Android平台。',
                ),

                // 联系方式
                _buildSectionWithButton(
                  context,
                  title: '联系方式',
                  content: '如有问题或建议，欢迎通过以下方式联系我们：',
                  buttonText: '发送邮件',
                  onPressed: () {
                    UrlService.openUrl('mailto:youngleepost@163.com');
                  },
                ),

                // 版权信息
                _buildSectionWithButton(
                  context,
                  title: '版权信息',
                  content: '本应用使用MIT开源协议，源代码托管在GitHub上。',
                  buttonText: '查看源代码',
                  onPressed: () {
                    UrlService.openUrl(
                      'https://github.com/YoungLee-coder/TomatoTime',
                    );
                  },
                ),

                // 鸣谢
                _buildSection(
                  context,
                  title: '鸣谢',
                  content:
                      '感谢所有为本项目提供支持和反馈的用户。\n'
                      '特别感谢Flutter团队提供的优秀开发框架。',
                ),

                const SizedBox(height: 40),

                // 版权声明
                Text(
                  '© 2025 YoungLee. All Rights Reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建内容区块
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建带按钮的内容区块
  Widget _buildSectionWithButton(
    BuildContext context, {
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
