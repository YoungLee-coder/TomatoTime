import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<Task> _tasks = [];
  List<Task> _todayTasks = [];
  Task? _currentTask;

  // 构造函数接收依赖
  TaskProvider({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  List<Task> get tasks => _tasks;
  List<Task> get todayTasks => _todayTasks;
  Task? get currentTask => _currentTask;

  // 初始化，加载所有任务
  Future<void> init() async {
    if (kIsWeb) {
      // Web平台上使用空数据
      _tasks = [];
      _todayTasks = [];
      notifyListeners();
      return;
    }

    await loadTasks();
    await loadTodayTasks();
  }

  // 加载所有任务
  Future<void> loadTasks() async {
    if (kIsWeb) {
      notifyListeners();
      return;
    }

    try {
      _tasks = await _databaseService.getTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('加载任务失败: $e');
      _tasks = [];
      notifyListeners();
    }
  }

  // 加载今日任务
  Future<void> loadTodayTasks() async {
    if (kIsWeb) {
      notifyListeners();
      return;
    }

    try {
      _todayTasks = await _databaseService.getTodayTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('加载今日任务失败: $e');
      _todayTasks = [];
      notifyListeners();
    }
  }

  // 添加新任务
  Future<bool> addTask(Task task) async {
    if (kIsWeb) {
      // 在Web环境中直接添加到内存列表
      final newTask = task.copyWith(id: DateTime.now().millisecondsSinceEpoch);
      _tasks.add(newTask);

      // 如果是今天的任务，也添加到今日任务列表
      final now = DateTime.now();
      if (task.date.year == now.year &&
          task.date.month == now.month &&
          task.date.day == now.day) {
        _todayTasks.add(newTask);
      }

      notifyListeners();
      return true;
    }

    try {
      // 在实际设备上使用数据库
      final id = await _databaseService.insertTask(task);
      if (id <= 0) {
        debugPrint('插入任务返回无效的ID: $id');
        return false;
      }

      debugPrint('成功插入任务，ID: $id');
      final newTask = task.copyWith(id: id);

      // 添加到内存中的任务列表
      _tasks.add(newTask);

      // 如果是今天的任务，也添加到今日任务列表
      final now = DateTime.now();
      if (task.date.year == now.year &&
          task.date.month == now.month &&
          task.date.day == now.day) {
        _todayTasks.add(newTask);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('添加任务失败: $e');
      return false;
    }
  }

  // 更新任务
  Future<bool> updateTask(Task task) async {
    try {
      final result = await _databaseService.updateTask(task);
      if (result <= 0) {
        return false;
      }

      // 更新总任务列表中的任务
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }

      // 更新今日任务列表中的任务
      final todayIndex = _todayTasks.indexWhere((t) => t.id == task.id);
      if (todayIndex != -1) {
        _todayTasks[todayIndex] = task;
      }

      // 如果是当前任务，也更新当前任务
      if (_currentTask?.id == task.id) {
        _currentTask = task;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新任务失败: $e');
      return false;
    }
  }

  // 删除任务
  Future<bool> deleteTask(int id) async {
    try {
      final result = await _databaseService.deleteTask(id);
      if (result <= 0) {
        return false;
      }

      _tasks.removeWhere((task) => task.id == id);
      _todayTasks.removeWhere((task) => task.id == id);

      if (_currentTask?.id == id) {
        _currentTask = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('删除任务失败: $e');
      return false;
    }
  }

  // 设置当前任务（用于番茄钟专注）
  void setCurrentTask(Task? task) {
    _currentTask = task;
    notifyListeners();
  }

  // 完成一个番茄钟
  Future<void> completePomodoro() async {
    if (_currentTask != null) {
      final updatedTask = _currentTask!.copyWith(
        completedPomodoros: _currentTask!.completedPomodoros + 1,
      );

      // 如果完成的番茄钟数量达到估计的番茄钟数量，则标记任务为已完成
      if (updatedTask.completedPomodoros >= updatedTask.estimatedPomodoros) {
        updatedTask.isCompleted = true;
      }

      await updateTask(updatedTask);
    }
  }

  // 刷新任务列表，用于从PomodoroProvider通知任务更新
  Future<void> refreshTasks() async {
    await loadTasks();
    await loadTodayTasks();
  }

  // 根据日期获取任务
  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final allTasks = await _databaseService.getTasks();
      return allTasks.where((task) {
        return task.date.year == date.year &&
            task.date.month == date.month &&
            task.date.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('获取任务失败: $e');
      return [];
    }
  }

  // 获取指定 ID 的任务
  Task? getTaskById(int id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      debugPrint('找不到任务: $e');
      return null;
    }
  }

  // 重置所有任务数据
  Future<bool> resetAllTasks() async {
    try {
      await _databaseService.clearTasks();
      _tasks = [];
      _todayTasks = [];
      _currentTask = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('重置任务失败: $e');
      return false;
    }
  }

  // 切换任务完成状态
  Future<bool> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    return await updateTask(updatedTask);
  }
}
