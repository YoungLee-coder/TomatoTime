import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';
import 'home_screen.dart';
import 'task_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TaskScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context);
    final isRunning = pomodoroProvider.isRunning;
    final state = pomodoroProvider.state;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer, size: 28),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist, size: 28),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon:
                isRunning
                    ? _buildRunningIcon(context, state)
                    : const Icon(Icons.insert_chart_outlined_rounded),
            activeIcon:
                isRunning
                    ? _buildRunningIcon(context, state, isActive: true)
                    : const Icon(Icons.insert_chart_rounded, size: 28),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_outlined),
            activeIcon: Icon(Icons.tune, size: 28),
            label: '设置',
          ),
        ],
        elevation: 8,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildRunningIcon(
    BuildContext context,
    PomodoroState state, {
    bool isActive = false,
  }) {
    final color =
        state == PomodoroState.focusing
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          isActive
              ? Icons.insert_chart_rounded
              : Icons.insert_chart_outlined_rounded,
          size: isActive ? 28 : 24,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
