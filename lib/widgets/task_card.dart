import 'package:flutter/material.dart';
import '../models/task.dart';

/// 任务卡片组件
/// 显示当前正在进行的任务详情
class TaskCard extends StatelessWidget {
  final Task task;
  final Color stateColor;
  final VoidCallback? onTap;
  final VoidCallback? onStartPomodoro;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.stateColor,
    this.onTap,
    this.onStartPomodoro,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: stateColor.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? Colors.green : task.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (task.isCompleted ? Colors.green : task.color)
                              .withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onStartPomodoro != null) ...[
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_outline,
                        color: stateColor,
                        size: 24,
                      ),
                      onPressed: onStartPomodoro,
                      tooltip: '开始番茄钟',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                  if (onToggleComplete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: task.isCompleted ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      onPressed: onToggleComplete,
                      tooltip: task.isCompleted ? '标记为未完成' : '标记为已完成',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red[300],
                        size: 24,
                      ),
                      onPressed: onDelete,
                      tooltip: '删除任务',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // 番茄钟进度
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: stateColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: stateColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '完成进度',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${task.completedPomodoros}/${task.estimatedPomodoros}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: task.isCompleted ? Colors.green : stateColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value:
                      task.estimatedPomodoros > 0
                          ? task.completedPomodoros / task.estimatedPomodoros
                          : 0,
                  minHeight: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    task.isCompleted ? Colors.green : stateColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
