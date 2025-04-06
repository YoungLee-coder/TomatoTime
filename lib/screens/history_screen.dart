import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';
import '../models/pomodoro_history.dart';
import '../utils/time_formatter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PomodoroHistory> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pomodoroProvider = Provider.of<PomodoroProvider>(
        context,
        listen: false,
      );
      final history = await pomodoroProvider.getHistory();

      setState(() {
        _historyList = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载历史记录失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _historyList.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.withAlpha(128)),
          const SizedBox(height: 16),
          const Text(
            '暂无历史记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '完成番茄钟后将在这里显示',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // 按日期分组
    final Map<String, List<PomodoroHistory>> groupedHistory = {};

    for (final item in _historyList) {
      final dateString = DateFormat('yyyy-MM-dd').format(item.startTime);
      if (!groupedHistory.containsKey(dateString)) {
        groupedHistory[dateString] = [];
      }
      groupedHistory[dateString]!.add(item);
    }

    // 排序日期，最近的在前
    final dates = groupedHistory.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final items = groupedHistory[date]!;

          return _buildDaySection(date, items);
        },
      ),
    );
  }

  Widget _buildDaySection(String dateString, List<PomodoroHistory> items) {
    final DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
    final bool isToday =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateString;
    final bool isYesterday =
        DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now().subtract(const Duration(days: 1))) ==
        dateString;

    String dateTitle;
    if (isToday) {
      dateTitle = '今天';
    } else if (isYesterday) {
      dateTitle = '昨天';
    } else {
      dateTitle = TimeFormatter.formatShortDate(date);
    }

    final totalDuration = items.fold<int>(
      0,
      (sum, item) => sum + item.duration,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                dateTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('(MM月dd日 E)').format(date),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const Spacer(),
              Text(
                '共 ${items.length} 个，${TimeFormatter.formatMinutes(totalDuration)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildHistoryItem(item)),
        const Divider(),
      ],
    );
  }

  Widget _buildHistoryItem(PomodoroHistory item) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task =
        item.taskId != null && item.taskId != '0'
            ? taskProvider.getTaskById(int.parse(item.taskId!))
            : null;

    // 根据状态确定显示内容
    IconData itemIcon;
    Color iconColor;
    String statusText;
    Color statusColor;

    switch (item.status) {
      case 'completed':
        itemIcon = Icons.timer;
        iconColor = Theme.of(context).colorScheme.primary;
        statusText = '番茄钟已完成';
        statusColor = Colors.green;
        break;
      case 'abandoned':
        itemIcon = Icons.timer_off;
        iconColor = Colors.red;
        statusText = '番茄钟已放弃';
        statusColor = Colors.red;
        break;
      case 'short_break_completed':
        itemIcon = Icons.coffee;
        iconColor = Theme.of(context).colorScheme.secondary;
        statusText = '短休息完成';
        statusColor = Colors.blue;
        break;
      case 'long_break_completed':
        itemIcon = Icons.weekend;
        iconColor = Theme.of(context).colorScheme.tertiary;
        statusText = '长休息完成';
        statusColor = Colors.purple;
        break;
      case 'break_completed':
        itemIcon = Icons.coffee;
        iconColor = Theme.of(context).colorScheme.secondary;
        statusText = '休息完成';
        statusColor = Colors.blue;
        break;
      default:
        itemIcon = Icons.timer_off;
        iconColor = Colors.orange;
        statusText = '已中断';
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(itemIcon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  TimeFormatter.formatTime(item.startTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.duration} 分钟',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (task != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: task.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                item.note!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
