import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:system_tray/system_tray.dart';

import 'models/task.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'screens/focus_active_screen.dart';
import 'screens/main_screen.dart';
import 'screens/task_detail_screen.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';
import 'utils/db_utils.dart';
import 'services/service_locator.dart';
import 'global/app_providers.dart';
import 'global/app_global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  await DbUtils.initializeDatabase();

  // Windows桌面平台配置
  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(900, 650),
      minimumSize: Size(600, 500),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Tomato Time', // 设置默认英文标题
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      // 使用window_manager动态设置中文标题
      await windowManager.setTitle('番茄时间');
    });

    // 初始化系统托盘
    try {
      await initSystemTray();
    } catch (e) {
      debugPrint('系统托盘初始化失败，但应用将继续运行: $e');
    }
  }

  // 初始化服务定位器
  final serviceLocator = ServiceLocator();
  await serviceLocator.init();

  // 初始化通知服务
  final notificationService = serviceLocator.notificationService;
  await notificationService.initNotification();

  runApp(AppProviders(serviceLocator: serviceLocator, child: const MyApp()));
}

// 初始化系统托盘
Future<void> initSystemTray() async {
  try {
    final SystemTray systemTray = SystemTray();

    // 设置图标 - 使用png格式的图标
    await systemTray.initSystemTray(
      title: "番茄时间",
      iconPath: 'assets/icon/app_icon.png',
    );

    // 创建托盘菜单
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: '显示', onClicked: (menuItem) => windowManager.show()),
      MenuItemLabel(label: '隐藏', onClicked: (menuItem) => windowManager.hide()),
      MenuSeparator(),
      MenuItemLabel(
        label: '退出',
        onClicked: (menuItem) => windowManager.close(),
      ),
    ]);

    // 设置托盘菜单
    await systemTray.setContextMenu(menu);

    // 点击托盘图标时的行为
    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows
            ? windowManager.show()
            : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        systemTray.popUpContextMenu();
      }
    });

    debugPrint('系统托盘初始化成功');
  } catch (e) {
    debugPrint('系统托盘初始化失败: $e');
    // 系统托盘初始化失败不应该影响应用程序的其他功能
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SettingsProvider _settingsProvider;
  late TaskProvider _taskProvider;
  late PomodoroProvider _pomodoroProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviders();
    });
  }

  // 初始化所有provider
  Future<void> _initProviders() async {
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _pomodoroProvider = Provider.of<PomodoroProvider>(context, listen: false);

    // 先加载设置
    await _settingsProvider.init();

    // 然后加载任务
    await _taskProvider.init();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return MaterialApp(
      title: '番茄时间',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(themeColor: settings.themeColor),
      darkTheme: AppTheme.getDarkTheme(themeColor: settings.themeColor),
      themeMode: settingsProvider.getFlutterThemeMode(),
      home: const MainScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/focus_active': (context) => const FocusActiveScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return MainScreen(initialIndex: args != null ? args as int : 0);
            },
          );
        }
        if (settings.name == '/task_detail') {
          final task = settings.arguments as Task;
          return MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          );
        }
        return null;
      },
    );
  }
}
