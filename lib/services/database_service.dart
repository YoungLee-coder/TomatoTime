import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/task.dart';
import '../models/pomodoro_history.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../utils/db_utils.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 处理web平台
    if (kIsWeb) {
      throw UnimplementedError("Web平台暂不支持SQLite");
    }

    String path = await DbUtils.getDatabasePath('pomodoro_app.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        estimatedPomodoros INTEGER NOT NULL,
        completedPomodoros INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pomodoro_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        duration INTEGER NOT NULL,
        taskId TEXT,
        taskTitle TEXT,
        status TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // 任务相关操作
  Future<int> insertTask(Task task) async {
    try {
      final db = await database;
      // 确保移除id字段，让数据库自动分配id
      final taskMap = task.toMap();
      if (taskMap.containsKey('id') && taskMap['id'] == null) {
        taskMap.remove('id');
      }

      // 确保日期字段格式正确
      if (taskMap.containsKey('date') && taskMap['date'] != null) {
        if (taskMap['date'] is DateTime) {
          taskMap['date'] = (taskMap['date'] as DateTime).toIso8601String();
        }
      }

      // 记录将要插入的数据
      debugPrint('即将插入任务: $taskMap');

      final id = await db.insert('tasks', taskMap);
      debugPrint('插入任务结果，ID: $id');
      return id;
    } catch (e) {
      debugPrint('insertTask错误: $e');
      return -1;
    }
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTodayTasks() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // 更新任务的指定字段
  Future<int> updateTaskFields(int id, Map<String, dynamic> values) async {
    final db = await database;
    return await db.update('tasks', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // 清除所有任务
  Future<void> clearTasks() async {
    final db = await database;
    await db.delete('tasks');
  }

  // 清除所有番茄钟历史记录
  Future<void> clearPomodoroHistory() async {
    final db = await database;
    await db.delete('pomodoro_history');
  }

  // 番茄钟历史相关操作
  Future<int> insertPomodoroHistory(PomodoroHistory history) async {
    try {
      final db = await database;
      // 把history.id转换为数据库的AUTOINCREMENT字段
      final historyMap = history.toMap();
      if (historyMap.containsKey('id')) {
        historyMap.remove('id');
      }
      return await db.insert('pomodoro_history', historyMap);
    } catch (e) {
      debugPrint('insertPomodoroHistory错误: $e');
      return -1;
    }
  }

  Future<List<PomodoroHistory>> getPomodoroHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_history',
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => PomodoroHistory.fromMap(maps[i]));
  }

  Future<List<PomodoroHistory>> getPomodoroHistoryByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_history',
      where: 'startTime BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'startTime DESC',
    );

    return List.generate(maps.length, (i) => PomodoroHistory.fromMap(maps[i]));
  }

  Future<int> deletePomodoroHistory(int id) async {
    final db = await database;
    return await db.delete(
      'pomodoro_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 统计方法
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final db = await database;

      // 获取总的番茄钟数量
      final totalPomodorosResult = await db.rawQuery(
        "SELECT COUNT(*) as count FROM pomodoro_history WHERE status = 'completed'",
      );
      final totalPomodoros = Sqflite.firstIntValue(totalPomodorosResult) ?? 0;

      // 获取总的专注时间（分钟）
      final totalFocusTimeResult = await db.rawQuery('''
        SELECT SUM(duration) as total 
        FROM pomodoro_history 
        WHERE status = 'completed'
      ''');
      final totalFocusTime =
          (totalFocusTimeResult.first['total'] as num?)?.toInt() ?? 0;

      // 获取今日完成的番茄钟数量
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final todayPomodorosResult = await db.rawQuery(
        '''
        SELECT COUNT(*) as count 
        FROM pomodoro_history 
        WHERE status = 'completed' AND startTime BETWEEN ? AND ?
      ''',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      final todayPomodoros = Sqflite.firstIntValue(todayPomodorosResult) ?? 0;

      // 获取今日专注时间（分钟）
      final todayFocusTimeResult = await db.rawQuery(
        '''
        SELECT SUM(duration) as total 
        FROM pomodoro_history 
        WHERE status = 'completed' AND startTime BETWEEN ? AND ?
      ''',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      final todayFocusTime =
          (todayFocusTimeResult.first['total'] as num?)?.toInt() ?? 0;

      // 获取已完成任务数
      final completedTasksResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 1',
      );
      final completedTasks = Sqflite.firstIntValue(completedTasksResult) ?? 0;

      return {
        'totalPomodoros': totalPomodoros,
        'totalFocusTime': totalFocusTime,
        'todayPomodoros': todayPomodoros,
        'todayFocusTime': todayFocusTime,
        'completedTasks': completedTasks,
      };
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

  // 获取过去7天每天的番茄钟完成数量
  Future<List<Map<String, dynamic>>> getWeeklyPomodoroStats() async {
    try {
      final db = await database;
      final result = <Map<String, dynamic>>[];

      final now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        final dailyCountResult = await db.rawQuery(
          '''
          SELECT COUNT(*) as count 
          FROM pomodoro_history 
          WHERE status = 'completed' AND startTime BETWEEN ? AND ?
        ''',
          [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        );

        final count = Sqflite.firstIntValue(dailyCountResult) ?? 0;

        result.add({'date': date, 'count': count});
      }

      return result;
    } catch (e) {
      debugPrint('获取周统计数据失败: $e');
      // 返回空数据结构
      final now = DateTime.now();
      final weeklyStats = <Map<String, dynamic>>[];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        weeklyStats.add({'date': date, 'count': 0});
      }

      return weeklyStats;
    }
  }

  // 获取每月的番茄钟统计
  Future<List<Map<String, dynamic>>> getMonthlyPomodoroStats() async {
    try {
      final db = await database;
      final result = <Map<String, dynamic>>[];

      final now = DateTime.now();

      for (int i = 0; i < 12; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        final startOfMonth = DateTime(month.year, month.month, 1);
        final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

        final monthlyCountResult = await db.rawQuery(
          '''
          SELECT COUNT(*) as count 
          FROM pomodoro_history 
          WHERE status = 'completed' AND startTime BETWEEN ? AND ?
        ''',
          [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
        );

        final count = Sqflite.firstIntValue(monthlyCountResult) ?? 0;

        result.add({'month': month, 'count': count});
      }

      return result.reversed.toList();
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
}
