import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'screens/focus_active_screen.dart';
import 'screens/main_screen.dart';
import 'screens/task_detail_screen.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知服务
  final notificationService = NotificationService();
  await notificationService.initNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
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

    // 设置PomodoroProvider的设置
    final settings = _settingsProvider.settings;
    _pomodoroProvider.setSettings(settings);

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
    final isDarkMode = settingsProvider.settings.darkMode;

    return MaterialApp(
      title: '番茄时间',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
