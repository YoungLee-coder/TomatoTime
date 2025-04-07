import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DbUtils {
  /// 初始化数据库
  static Future<void> initializeDatabase() async {
    // 针对不同平台使用不同的数据库工厂
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // 桌面平台使用FFI
      // 初始化FFI
      sqfliteFfiInit();
      // 设置全局数据库工厂为FFI工厂
      databaseFactory = databaseFactoryFfi;
      debugPrint('使用FFI数据库工厂初始化');
    } else {
      debugPrint('使用默认数据库工厂初始化');
    }
  }

  /// 获取数据库路径
  static Future<String> getDatabasePath(String dbName) async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, dbName);
  }
}
