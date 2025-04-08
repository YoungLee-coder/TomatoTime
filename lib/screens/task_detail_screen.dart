import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/time_formatter.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _estimatedPomodoros = 1;
  Color _selectedColor = Colors.red;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      // 编辑现有任务
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.date;
      _estimatedPomodoros = widget.task!.estimatedPomodoros;
      _selectedColor = widget.task!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑任务' : '创建任务'),
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                widget.task!.isCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: widget.task!.isCompleted ? Colors.green : null,
              ),
              onPressed: _toggleTaskCompletion,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 任务标题
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '任务标题',
                  hintText: '输入任务标题',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入任务标题';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 任务描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '任务描述（可选）',
                  hintText: '输入任务描述',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // 日期选择
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('日期'),
                subtitle: Text(TimeFormatter.formatDate(_selectedDate)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: _selectDate,
              ),

              const SizedBox(height: 16),

              // 预计番茄钟数量
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('预计番茄钟数量'),
                subtitle: Text('$_estimatedPomodoros 个'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          _estimatedPomodoros > 1
                              ? () {
                                setState(() {
                                  _estimatedPomodoros--;
                                });
                              }
                              : null,
                    ),
                    Text(
                      '$_estimatedPomodoros',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          _estimatedPomodoros++;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 颜色选择
              const Text(
                '任务颜色',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = _selectedColor.value == color.value;
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? color.withOpacity(0.6)
                                      : Colors.black.withOpacity(0.1),
                              blurRadius: isSelected ? 10 : 4,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    isEditing ? '保存修改' : '创建任务',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              if (isEditing) ...[
                const SizedBox(height: 16),

                // 删除按钮
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _confirmDeleteTask,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('删除任务', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  // 保存任务
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasks = taskProvider.tasks;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    bool success = false;

    if (widget.task != null) {
      // 更新现有任务
      final updatedTask = widget.task!.copyWith(
        title: title,
        description: description,
        date: _selectedDate,
        estimatedPomodoros: _estimatedPomodoros,
        color: _selectedColor,
      );

      success = await taskProvider.updateTask(updatedTask);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('任务已更新')));
          Navigator.of(context).pop(true); // 返回true表示成功
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('更新任务失败，请重试')));
        }
      }
    } else {
      // 创建新任务前检查是否存在重名任务
      bool isDuplicate = false;
      for (var task in tasks) {
        if (task.title.toLowerCase() == title.toLowerCase()) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        // 显示错误提示
        if (context.mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('任务名称重复'),
                  content: Text('已存在名为"$title"的任务，请使用不同的名称。'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('确定'),
                    ),
                  ],
                ),
          );
        }
        return;
      }

      // 创建新任务
      try {
        final newTask = Task(
          title: title,
          description: description,
          date: _selectedDate,
          estimatedPomodoros: _estimatedPomodoros,
          color: _selectedColor,
        );

        success = await taskProvider.addTask(newTask);
        if (success) {
          if (context.mounted) {
            Navigator.of(context).pop(true); // 返回true表示成功
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('创建任务失败，请重试')));
          }
        }
      } catch (e) {
        debugPrint('创建任务时发生错误: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('创建任务时发生错误: $e')));
        }
      }
    }
  }

  // 切换任务完成状态
  void _toggleTaskCompletion() {
    if (widget.task != null) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final updatedTask = widget.task!.copyWith(
        isCompleted: !widget.task!.isCompleted,
      );

      taskProvider.updateTask(updatedTask).then((success) {
        if (success) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updatedTask.isCompleted ? '任务已标记为已完成' : '任务已标记为未完成',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('更新任务状态失败，请重试')));
        }
      });
    }
  }

  // 确认删除任务
  void _confirmDeleteTask() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除任务"${widget.task!.title}"吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  final taskProvider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );
                  taskProvider.deleteTask(widget.task!.id!).then((success) {
                    Navigator.of(context).pop(); // 关闭对话框
                    if (success) {
                      Navigator.of(context).pop(); // 返回上一页
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('任务已删除')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('删除任务失败，请重试')),
                      );
                    }
                  });
                },
                child: const Text('删除'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}
