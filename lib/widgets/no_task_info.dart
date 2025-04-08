import 'package:flutter/material.dart';

/// 无任务信息卡片组件
/// 当没有关联任务时显示的提示信息
class NoTaskInfo extends StatelessWidget {
  final Color stateColor;

  const NoTaskInfo({super.key, required this.stateColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: stateColor.withOpacity(0.1), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!.withOpacity(0.8)
                  : Colors.white.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stateColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timer_outlined, color: stateColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '专注不需要关联任务。您可以在结束后记录此次专注。',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
