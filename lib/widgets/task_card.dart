import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onStartPomodoro;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onStartPomodoro,
    this.onToggleComplete,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: task.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              task.isCompleted
                  ? Colors.green.withOpacity(0.5)
                  : task.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: task.color.withOpacity(0.1),
        highlightColor: task.color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 任务状态指示器 - 添加点击功能
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: task.isCompleted ? Colors.green : task.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (task.isCompleted
                                    ? Colors.green
                                    : task.color)
                                .withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child:
                          task.isCompleted
                              ? const Icon(
                                Icons.check,
                                size: 10,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 任务标题和描述
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration:
                                task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                            color:
                                task.isCompleted
                                    ? theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.6)
                                    : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 完成按钮
                  if (onToggleComplete != null && !task.isCompleted)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      onPressed: onToggleComplete,
                      color: Colors.green,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: '标记完成',
                    ),

                  // 删除按钮
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      color: theme.colorScheme.error,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: '删除任务',
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 番茄钟进度和操作
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 番茄钟进度
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${task.completedPomodoros}/${task.estimatedPomodoros}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value:
                                  task.estimatedPomodoros > 0
                                      ? task.completedPomodoros /
                                          task.estimatedPomodoros
                                      : 0,
                              minHeight: 8,
                              backgroundColor: theme.colorScheme.surfaceVariant
                                  .withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                task.isCompleted ? Colors.green : task.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 开始番茄钟按钮
                  if (onStartPomodoro != null && !task.isCompleted)
                    ElevatedButton.icon(
                      onPressed: onStartPomodoro,
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('开始'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: task.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
