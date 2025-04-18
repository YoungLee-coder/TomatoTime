import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/pomodoro_history.dart';
import '../models/settings.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';

enum PomodoroState {
  idle, // 空闲状态
  focusing, // 专注状态
  shortBreak, // 短休息
  longBreak, // 长休息
  paused, // 暂停状态
}

class PomodoroProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final NotificationService _notificationService;
  final SoundService _soundService;
  final VibrationService _vibrationService;

  PomodoroState _state = PomodoroState.idle;
  PomodoroState _previousActiveState = PomodoroState.idle; // 用于记录暂停前的状态
  Timer? _timer;
  int _timeRemaining = 0; // 剩余时间（秒）
  int _initialTime = 0; // 初始设置的时间（秒）
  int _completedPomodoros = 0; // 已完成的番茄钟数量
  Task? _currentTask;
  Task? _lastTask; // 保存最后一个任务的引用，用于自动开始下一个番茄钟
  bool _needRefreshTasks = false; // 标志是否需要刷新任务列表
  VoidCallback? _onReturnToHome; // 返回首页的回调函数
  bool _manualStateChange = false; // 标志是否手动切换状态，用于控制自动开始休息的逻辑

  PomodoroSettings _settings;
  DateTime? _startTime;
  bool _isRunning = false;
  double _progress = 0.0;
  int _totalTime = 0;

  PomodoroProvider({
    required PomodoroSettings settings,
    required NotificationService notificationService,
    SoundService? soundService,
    VibrationService? vibrationService,
    DatabaseService? databaseService,
  }) : _settings = settings,
       _notificationService = notificationService,
       _soundService = soundService ?? SoundService(),
       _vibrationService = vibrationService ?? VibrationService(),
       _databaseService = databaseService ?? DatabaseService() {
    _initializeServices();
  }

  // getters
  PomodoroState get state => _state;
  bool get isRunning => _timer != null && _timer!.isActive;
  int get timeRemaining => _timeRemaining;
  int get initialTime => _initialTime;
  double get progress => _progress;
  Task? get currentTask => _currentTask;
  PomodoroSettings get settings => _settings;
  bool get needRefreshTasks => _needRefreshTasks;
  PomodoroState get previousActiveState => _previousActiveState;
  int get completedPomodoros => _completedPomodoros;
  NotificationService get notificationService => _notificationService;

  // 设置返回首页的回调
  void setReturnToHomeCallback(VoidCallback callback) {
    _onReturnToHome = callback;
  }

  // 重置任务刷新标志
  void resetRefreshTasksFlag() {
    _needRefreshTasks = false;
  }

  void setSettings(PomodoroSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void setCurrentTask(Task? task) {
    _currentTask = task;
    if (task != null) {
      _lastTask = task; // 同时保存到最后一个任务引用
    }
    notifyListeners();
  }

  // 设置手动状态切换标志
  void setManualStateChange(bool value) {
    _manualStateChange = value;
  }

  // 重置番茄钟状态
  void reset() {
    _stopTimer();
    _state = PomodoroState.idle;
    _previousActiveState = PomodoroState.idle;
    _timeRemaining = 0;
    _initialTime = 0;
    _startTime = null;
    notifyListeners();
  }

  // 重置所有番茄钟历史记录
  Future<bool> resetAllHistory() async {
    try {
      if (kIsWeb) {
        // Web平台简单处理
        notifyListeners();
        return true;
      }

      await _databaseService.clearPomodoroHistory();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('重置番茄钟历史失败: $e');
      return false;
    }
  }

  // 开始专注
  void startFocus([BuildContext? context]) {
    _manualStateChange = true; // 设置手动状态切换标志
    _stopTimer();
    _state = PomodoroState.focusing;
    _previousActiveState = PomodoroState.focusing;
    _timeRemaining = _settings.focusDuration * 60;
    _initialTime = _timeRemaining;
    _startTime = DateTime.now();
    _startTimer(context);

    // 如果通知开启，则在结束时安排通知
    if (_settings.notificationsEnabled) {
      _notificationService.scheduleFocusEndNotification(
        1,
        Duration(minutes: _settings.focusDuration),
      );
    }

    // 根据设置播放开始提示音
    if (_settings.soundEnabled) {
      _soundService.playStartSound();
      debugPrint('播放开始提示音');
    }

    _manualStateChange = false; // 重置标志
    notifyListeners();
  }

  // 开始短休息
  void startShortBreak([BuildContext? context]) {
    _manualStateChange = true; // 设置手动状态切换标志
    _stopTimer();
    _state = PomodoroState.shortBreak;
    _previousActiveState = PomodoroState.shortBreak;
    _timeRemaining = _settings.shortBreakDuration * 60;
    _initialTime = _timeRemaining;
    _startTime = DateTime.now();
    _startTimer(context);

    // 如果通知开启，则在结束时安排通知
    if (_settings.notificationsEnabled) {
      _notificationService.scheduleBreakEndNotification(
        2,
        Duration(minutes: _settings.shortBreakDuration),
      );
    }

    // 根据设置播放开始提示音
    if (_settings.soundEnabled) {
      _soundService.playStartSound();
      debugPrint('播放开始提示音');
    }

    _manualStateChange = false; // 重置标志
    notifyListeners();
  }

  // 开始长休息
  void startLongBreak([BuildContext? context]) {
    _manualStateChange = true; // 设置手动状态切换标志
    _stopTimer();
    _state = PomodoroState.longBreak;
    _previousActiveState = PomodoroState.longBreak;
    _timeRemaining = _settings.longBreakDuration * 60;
    _initialTime = _timeRemaining;
    _startTime = DateTime.now();
    _startTimer(context);

    // 如果通知开启，则在结束时安排通知
    if (_settings.notificationsEnabled) {
      _notificationService.scheduleBreakEndNotification(
        3,
        Duration(minutes: _settings.longBreakDuration),
      );
    }

    // 根据设置播放开始提示音
    if (_settings.soundEnabled) {
      _soundService.playStartSound();
      debugPrint('播放开始提示音');
    }

    _manualStateChange = false; // 重置标志
    notifyListeners();
  }

  // 暂停计时器
  void pause() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _previousActiveState = _state; // 记录暂停前的状态
      _state = PomodoroState.paused;

      // 取消所有通知
      _notificationService.cancelAllNotifications();

      notifyListeners();
    }
  }

  // 继续计时器
  void resume([BuildContext? context]) {
    if (_state == PomodoroState.paused) {
      // 停止可能存在的计时器
      _stopTimer();

      // 恢复到暂停前的状态
      _state = _previousActiveState;

      // 开始计时器
      _startTimer(context);

      // 重新安排通知
      if (_settings.notificationsEnabled) {
        if (_state == PomodoroState.focusing) {
          _notificationService.scheduleFocusEndNotification(
            1,
            Duration(seconds: _timeRemaining),
          );
        } else {
          _notificationService.scheduleBreakEndNotification(
            2,
            Duration(seconds: _timeRemaining),
          );
        }
      }

      // 根据设置播放开始提示音
      if (_settings.soundEnabled) {
        _soundService.playStartSound();
        debugPrint('播放开始提示音');
      }

      notifyListeners();
    }
  }

  // 停止计时器
  void stop() {
    _stopTimer();
    _state = PomodoroState.idle;
    _previousActiveState = PomodoroState.idle;
    _timeRemaining = 0;
    _initialTime = 0;
    _startTime = null;

    // 清除当前任务
    _currentTask = null;

    // 取消所有通知
    _notificationService.cancelAllNotifications();

    notifyListeners();
  }

  // 提前完成专注
  Future<void> finishEarly(BuildContext? context) async {
    // 只有在专注状态或暂停状态下才能提前完成
    if (_state == PomodoroState.focusing ||
        (_state == PomodoroState.paused &&
            _previousActiveState == PomodoroState.focusing)) {
      // 停止当前的计时器
      _stopTimer();

      // 取消所有通知
      _notificationService.cancelAllNotifications();

      // 记录专注完成
      _completedPomodoros++;

      // 记录当前任务的引用，以备后用
      Task? taskToUpdate = _currentTask;

      // 如果有关联任务，记录历史并更新任务
      if (taskToUpdate != null && _startTime != null) {
        await _savePomodoroHistory();
        debugPrint('提前结束：已保存番茄钟历史并更新任务 ID: ${taskToUpdate.id}');

        // 如果提供了context，直接刷新任务列表
        if (context != null) {
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );
          await taskProvider.refreshTasks();
          debugPrint('提前结束：已直接刷新任务列表');
        } else {
          // 仍然设置标志，以便轮询机制可以刷新任务
          _needRefreshTasks = true;
        }
      } else {
        // 即使没有关联任务，也应记录番茄钟历史
        await _saveCompletedPomodoroWithoutTask();
      }

      // 重要：保存历史记录和更新任务后再清除当前任务引用
      _currentTask = null;

      // 显示通知
      if (_settings.notificationsEnabled) {
        await _notificationService.showNotification(
          id: 3,
          title: '专注提前完成',
          body: '您已提前完成本次番茄钟，进度已记录。',
        );
      }

      // 根据设置决定下一步
      if (_settings.autoStartBreaks && !_manualStateChange) {
        // 根据完成的番茄钟数量决定是短休息还是长休息
        if (_completedPomodoros % _settings.longBreakInterval == 0) {
          startLongBreak();
        } else {
          startShortBreak();
        }
      } else if (!_manualStateChange) {
        // 只有在非手动状态切换时才设为空闲状态并返回首页
        _state = PomodoroState.idle;
        notifyListeners();

        // 调用返回首页回调
        if (_onReturnToHome != null) {
          _onReturnToHome!();
        }
      } else {
        // 手动状态切换时，只需要重置状态
        _state = PomodoroState.idle;
        notifyListeners();
      }
    }
  }

  // 提前结束休息
  Future<void> finishBreakEarly(BuildContext? context) async {
    // 只有在休息状态或暂停状态下才能提前结束休息
    if ((_state == PomodoroState.shortBreak ||
            _state == PomodoroState.longBreak) ||
        (_state == PomodoroState.paused &&
            (_previousActiveState == PomodoroState.shortBreak ||
                _previousActiveState == PomodoroState.longBreak))) {
      // 停止当前的计时器
      _stopTimer();

      // 取消所有通知
      _notificationService.cancelAllNotifications();

      // 保存休息历史记录
      if (_startTime != null) {
        await _savePomodoroHistory();
        debugPrint('已保存休息提前结束历史');
      }

      // 显示通知
      if (_settings.notificationsEnabled) {
        await _notificationService.showNotification(
          id: 5,
          title: '休息已结束',
          body: '您已提前结束休息，可以开始新的专注了。',
        );
      }

      // 根据设置决定下一步
      if (_settings.autoStartPomodoros &&
          _lastTask != null &&
          !_manualStateChange) {
        _startTime = null;
        setCurrentTask(_lastTask); // 重新设置之前保存的任务
        startFocus(); // 自动开始下一个番茄钟
      } else if (!_manualStateChange) {
        // 只有在非手动状态切换时才设为空闲状态并返回首页
        _state = PomodoroState.idle;
        notifyListeners();

        // 调用返回首页回调
        if (_onReturnToHome != null) {
          _onReturnToHome!();
        }
      } else {
        // 手动状态切换时，只需要重置状态
        _state = PomodoroState.idle;
        notifyListeners();
      }
    }
  }

  // 放弃番茄钟
  Future<void> abandonPomodoro(BuildContext? context) async {
    // 只有在专注状态或暂停状态下才能放弃
    if (_state == PomodoroState.focusing ||
        (_state == PomodoroState.paused &&
            _previousActiveState == PomodoroState.focusing)) {
      // 停止当前的计时器
      _stopTimer();

      // 取消所有通知
      _notificationService.cancelAllNotifications();

      // 记录放弃的番茄钟历史（标记为放弃状态）
      if (_startTime != null) {
        try {
          // 创建历史记录
          final history = PomodoroHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            startTime: _startTime!,
            endTime: DateTime.now(),
            duration: (_initialTime - _timeRemaining) ~/ 60, // 实际专注时长（分钟）
            taskId: _currentTask?.id?.toString() ?? '0',
            status: 'abandoned', // 标记为放弃状态
          );

          await _databaseService.insertPomodoroHistory(history);
          debugPrint('已保存放弃的番茄钟历史');
        } catch (e) {
          debugPrint('保存放弃番茄钟历史失败: $e');
        }
      }

      // 清除当前任务引用（注意：放弃番茄钟不会更新任务的完成状态）
      Task? taskReference = _currentTask;
      _currentTask = null;

      // 如果提供了context且有关联任务，刷新任务列表
      if (context != null && taskReference != null) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        await taskProvider.refreshTasks();
        debugPrint('放弃番茄钟：已刷新任务列表');
      }

      // 显示通知
      if (_settings.notificationsEnabled) {
        await _notificationService.showNotification(
          id: 4,
          title: '已放弃番茄钟',
          body: '您已放弃本次番茄钟，可以随时重新开始。',
        );
      }

      // 设置为空闲状态
      _state = PomodoroState.idle;
      notifyListeners();

      // 调用返回首页回调
      if (_onReturnToHome != null) {
        _onReturnToHome!();
      }
    }
  }

  // 没有关联任务时保存番茄钟历史
  Future<void> _saveCompletedPomodoroWithoutTask() async {
    if (_startTime == null) return;

    try {
      // 创建历史记录
      final history = PomodoroHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _startTime!,
        endTime: DateTime.now(),
        duration: (_initialTime - _timeRemaining) ~/ 60, // 实际专注时长（分钟）
        taskId: '0', // 没有关联任务使用0作为ID
        status: 'completed',
      );

      await _databaseService.insertPomodoroHistory(history);
    } catch (e) {
      debugPrint('保存无任务番茄钟历史记录失败: $e');
    }
  }

  // 保存番茄钟历史记录
  Future<void> _savePomodoroHistory() async {
    if (_startTime == null) return;

    try {
      // 确定当前状态和记录状态
      String status = 'completed';
      String? taskId = _currentTask?.id?.toString();

      // 根据状态设置不同的记录标记
      if (_state == PomodoroState.shortBreak ||
          (_state == PomodoroState.paused &&
              _previousActiveState == PomodoroState.shortBreak)) {
        status = 'short_break_completed';
        taskId = '0'; // 休息没有关联任务
      } else if (_state == PomodoroState.longBreak ||
          (_state == PomodoroState.paused &&
              _previousActiveState == PomodoroState.longBreak)) {
        status = 'long_break_completed';
        taskId = '0'; // 休息没有关联任务
      }

      // 创建历史记录
      final history = PomodoroHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _startTime!,
        endTime: DateTime.now(),
        duration: (_initialTime - _timeRemaining) ~/ 60, // 实际专注/休息时长（分钟）
        taskId: taskId,
        status: status,
      );

      await _databaseService.insertPomodoroHistory(history);
      debugPrint('保存历史记录成功: 状态=${history.status}, 时长=${history.duration}分钟');

      // 如果是专注时间且关联了任务，增加任务的已完成番茄钟数
      if (status == 'completed' && _currentTask != null) {
        int completedPomodoros = _currentTask!.completedPomodoros + 1;
        bool isCompleted =
            completedPomodoros >= _currentTask!.estimatedPomodoros;

        // 创建更新后的任务对象
        final updatedTask = _currentTask!.copyWith(
          completedPomodoros: completedPomodoros,
          isCompleted: isCompleted,
        );

        // 使用任务对象更新数据库，确保所有字段都正确更新
        await _databaseService.updateTask(updatedTask);

        // 更新内存中的任务引用
        _currentTask = updatedTask;
        _lastTask = updatedTask;

        // 设置刷新标志，通知外部需要刷新任务列表
        _needRefreshTasks = true;
        debugPrint(
          '任务进度已更新: $_needRefreshTasks, ID: ${updatedTask.id}, 完成数: $completedPomodoros',
        );
      }
    } catch (e) {
      debugPrint('保存番茄钟历史记录失败: $e');
    }
  }

  // 开始计时器
  void _startTimer([BuildContext? context]) {
    // 如果设置了屏幕常亮，则启用它
    if (_settings.keepScreenAwake && !kIsWeb) {
      try {
        // 使用WakelockPlus保持屏幕常亮
        WakelockPlus.enable();
        debugPrint('已启用屏幕常亮');
      } catch (e) {
        debugPrint('无法启用屏幕常亮: $e');
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _timer = null;

        // 处理完成逻辑
        _handleCompletion(context);
      }
    });
  }

  // 停止计时器
  void _stopTimer() {
    // 如果启用了屏幕常亮，则解除它
    if (_settings.keepScreenAwake && !kIsWeb) {
      try {
        // 使用WakelockPlus禁用屏幕常亮
        WakelockPlus.disable();
        debugPrint('已禁用屏幕常亮');
      } catch (e) {
        debugPrint('无法禁用屏幕常亮: $e');
      }
    }

    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }

  // 处理完成的逻辑
  Future<void> _handleCompletion([BuildContext? context]) async {
    // 停止计时器
    _timer?.cancel();
    _timer = null;

    // 如果在专注状态，则增加完成的番茄钟数量
    if (_state == PomodoroState.focusing) {
      _completedPomodoros++;

      // 保存当前任务引用
      Task? taskToUpdate = _currentTask;

      // 保存番茄钟历史
      await _savePomodoroHistory();

      // 直接刷新任务列表，如果提供了context
      if (context != null && taskToUpdate != null) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        await taskProvider.refreshTasks();
        debugPrint('番茄钟完成：已直接刷新任务列表');
      } else if (taskToUpdate != null) {
        // 仍然设置标志，以便轮询机制可以刷新任务
        _needRefreshTasks = true;
      }

      // 如果有关联任务，则保存最后的任务引用，用于自动开始下一个番茄钟
      if (taskToUpdate != null) {
        _lastTask = taskToUpdate;
      }

      // 根据设置决定下一步操作
      if (_settings.autoStartBreaks) {
        // 自动开始休息
        _startTime = null;
        // 清除当前任务，因为已经保存到_lastTask中
        _currentTask = null;

        if (_completedPomodoros % _settings.longBreakInterval == 0) {
          // 每完成4个番茄钟，进行一次长休息
          startLongBreak();
        } else {
          // 否则进行短休息
          startShortBreak();
        }
        // 发送通知
        if (_settings.notificationsEnabled) {
          await _notificationService.showNotification(
            id: 1,
            title: '专注结束',
            body: '恭喜你完成了一个番茄钟！现在可以休息一下了。',
          );
        }
      } else {
        // 不自动开始休息，回到空闲状态
        _state = PomodoroState.idle;
        _currentTask = null; // 清除当前任务
        notifyListeners();

        // 发送通知
        if (_settings.notificationsEnabled) {
          await _notificationService.showNotification(
            id: 1,
            title: '专注结束',
            body: '太棒了，您已完成一个番茄钟！',
          );
        }

        // 调用返回首页回调
        if (_onReturnToHome != null) {
          _onReturnToHome!();
        }
      }

      // 根据设置播放声音和触发振动
      if (_settings.soundEnabled) {
        _soundService.playCompletionSound();
        debugPrint('播放专注完成提示音');
      }

      if (_settings.vibrationEnabled) {
        _vibrationService.vibrateFocusEnd();
        debugPrint('触发专注完成振动');
      }
    } else if (_state == PomodoroState.shortBreak ||
        _state == PomodoroState.longBreak) {
      // 保存休息历史记录
      await _savePomodoroHistory();

      // 根据设置决定是否自动开始下一个番茄钟
      if (_settings.autoStartPomodoros && _lastTask != null) {
        _startTime = null;
        setCurrentTask(_lastTask); // 重新设置之前保存的任务
        startFocus(); // 自动开始下一个番茄钟

        // 发送通知
        if (_settings.notificationsEnabled) {
          await _notificationService.showNotification(
            id: 2,
            title: '休息结束',
            body: '休息时间结束了，准备开始下一个番茄钟吧！',
          );
        }
      } else {
        // 不自动开始下一个番茄钟，回到空闲状态
        _state = PomodoroState.idle;
        _currentTask = null; // 清除当前任务
        notifyListeners();

        // 发送通知
        if (_settings.notificationsEnabled) {
          await _notificationService.showNotification(
            id: 2,
            title: '休息结束',
            body: '休息已完成，随时可以开始新的专注！',
          );
        }

        // 调用返回首页回调
        if (_onReturnToHome != null) {
          _onReturnToHome!();
        }
      }

      // 根据设置播放声音和触发振动
      if (_settings.soundEnabled) {
        _soundService.playCompletionSound();
        debugPrint('播放休息完成提示音');
      }

      if (_settings.vibrationEnabled) {
        _vibrationService.vibrateBreakEnd();
        debugPrint('触发休息完成振动');
      }
    }
  }

  // 获取所有番茄钟历史记录
  Future<List<PomodoroHistory>> getHistory() async {
    if (kIsWeb) {
      // Web平台返回空数据
      return [];
    }

    try {
      return await _databaseService.getPomodoroHistory();
    } catch (e) {
      debugPrint('获取历史记录失败: $e');
      return [];
    }
  }

  // 获取统计数据
  Future<Map<String, dynamic>> getStatistics() async {
    if (kIsWeb) {
      // Web平台返回空数据
      return {
        'totalPomodoros': 0,
        'totalFocusTime': 0,
        'todayPomodoros': 0,
        'todayFocusTime': 0,
        'completedTasks': 0,
      };
    }

    try {
      return await _databaseService.getStatistics();
    } catch (e) {
      debugPrint('获取统计数据失败: $e');
      return {
        'totalPomodoros': 0,
        'totalFocusTime': 0,
        'todayPomodoros': 0,
        'todayFocusTime': 0,
        'completedTasks': 0,
      };
    }
  }

  // 获取每周统计数据
  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    if (kIsWeb) {
      // Web平台返回空数据
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weeklyStats = <Map<String, dynamic>>[];

      for (int i = 0; i < 7; i++) {
        final date = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        ).add(Duration(days: i));
        weeklyStats.add({'date': date, 'count': 0});
      }

      return weeklyStats;
    }

    try {
      return await _databaseService.getWeeklyPomodoroStats();
    } catch (e) {
      debugPrint('获取周统计数据失败: $e');
      // 返回空数据结构
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weeklyStats = <Map<String, dynamic>>[];

      for (int i = 0; i < 7; i++) {
        final date = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        ).add(Duration(days: i));
        weeklyStats.add({'date': date, 'count': 0});
      }

      return weeklyStats;
    }
  }

  // 获取每月统计数据
  Future<List<Map<String, dynamic>>> getMonthlyStats() async {
    if (kIsWeb) {
      // Web平台返回空数据
      final now = DateTime.now();
      final monthlyStats = <Map<String, dynamic>>[];

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        monthlyStats.add({'month': month, 'count': 0});
      }

      return monthlyStats;
    }

    try {
      return await _databaseService.getMonthlyPomodoroStats();
    } catch (e) {
      debugPrint('获取月统计数据失败: $e');
      // 返回空数据结构
      final now = DateTime.now();
      final monthlyStats = <Map<String, dynamic>>[];

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        monthlyStats.add({'month': month, 'count': 0});
      }

      return monthlyStats;
    }
  }

  Future<void> _initializeServices() async {
    await _soundService.init();
    debugPrint('声音服务初始化完成');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundService.dispose();
    super.dispose();
  }
}
