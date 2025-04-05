import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/statistics_card.dart';
import '../utils/time_formatter.dart';
import '../models/pomodoro_history.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _weeklyStats = [];
  List<Map<String, dynamic>> _monthlyStats = [];
  List<PomodoroHistory> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pomodoroProvider = Provider.of<PomodoroProvider>(
        context,
        listen: false,
      );

      final stats = await pomodoroProvider.getStatistics();
      final weeklyStats = await pomodoroProvider.getWeeklyStats();
      final monthlyStats = await pomodoroProvider.getMonthlyStats();

      setState(() {
        _statistics = stats;
        _weeklyStats = weeklyStats;
        _monthlyStats = monthlyStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载统计数据失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

      // 调试信息
      debugPrint('加载历史记录: ${history.length} 条');
      if (history.isNotEmpty) {
        debugPrint('第一条记录: ${history.first.toMap()}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('加载历史记录失败: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载历史记录失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshAll() async {
    await _loadStatistics();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshAll),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '周统计'), Tab(text: '月统计'), Tab(text: '历史记录')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeeklyStatsTab(),
                    _buildMonthlyStatsTab(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
    );
  }

  Widget _buildWeeklyStatsTab() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计卡片
            _buildStatisticsCards(),

            // 本周数据图表
            const SizedBox(height: 24),
            WeeklyChart(data: _weeklyStats),

            // 本周每日数据
            const SizedBox(height: 24),
            _buildWeeklyDetailList(),

            // 底部安全区域
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatsTab() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计卡片
            _buildStatisticsCards(),

            // 月度数据图表
            const SizedBox(height: 24),
            _buildMonthlyChartCard(),

            // 月度数据列表
            const SizedBox(height: 24),
            _buildMonthlyDetailList(),

            // 底部安全区域
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final totalPomodoros = _statistics['totalPomodoros'] ?? 0;
    final totalFocusTime = _statistics['totalFocusTime'] ?? 0;
    final todayPomodoros = _statistics['todayPomodoros'] ?? 0;
    final todayFocusTime = _statistics['todayFocusTime'] ?? 0;
    final completedTasks = _statistics['completedTasks'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width > 600;

        // 针对宽屏采用4列布局，窄屏采用2列布局
        if (isWide) {
          // 宽屏4列布局
          return Row(
            children: [
              Expanded(
                child: StatisticsCard(
                  title: '今日番茄钟',
                  value: '$todayPomodoros 个',
                  icon: Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatisticsCard(
                  title: '今日专注时间',
                  value: _getFormattedDuration(todayFocusTime),
                  icon: Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatisticsCard(
                  title: '总番茄钟',
                  value: '$totalPomodoros 个',
                  icon: Icons.bar_chart,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatisticsCard(
                  title: '总专注时间',
                  value: _getFormattedDuration(totalFocusTime),
                  icon: Icons.hourglass_bottom,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          );
        } else {
          // 窄屏2列布局
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatisticsCard(
                      title: '今日番茄钟',
                      value: '$todayPomodoros 个',
                      icon: Icons.timer,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsCard(
                      title: '今日专注时间',
                      value: _getFormattedDuration(todayFocusTime),
                      icon: Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsCard(
                      title: '总番茄钟',
                      value: '$totalPomodoros 个',
                      icon: Icons.bar_chart,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsCard(
                      title: '总专注时间',
                      value: _getFormattedDuration(totalFocusTime),
                      icon: Icons.hourglass_bottom,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildWeeklyDetailList() {
    if (_weeklyStats.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('没有本周数据')),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每日详情',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(_weeklyStats.length, (index) {
              final item = _weeklyStats[index];
              final date = item['date'] as DateTime;
              final count = item['count'] as int;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TimeFormatter.formatShortDate(date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${count == 0 ? "没有" : count.toString()} 个番茄钟',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            count > 0
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: count > 0 ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChartCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isDark
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      color:
          isDark ? colorScheme.surfaceVariant.withOpacity(0.5) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '月度番茄钟统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '总计: ${_getMonthlyTotal()}个',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child:
                  _monthlyStats.isEmpty
                      ? _buildEmptyState('本年度暂无数据')
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          // 确保图表宽度足够大以支持滚动
                          width: max(
                            MediaQuery.of(context).size.width - 32,
                            _monthlyStats.length * 60.0,
                          ),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _getMaxMonthlyValue() * 1.2,
                              minY: 0,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor:
                                      isDark
                                          ? colorScheme.surface
                                          : colorScheme.secondary,
                                  tooltipRoundedRadius: 8,
                                  tooltipMargin: 8,
                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    final month =
                                        _monthlyStats[group.x.toInt()]['month']
                                            as DateTime;
                                    return BarTooltipItem(
                                      '${DateFormat('yyyy年M月').format(month)}\n${rod.toY.toInt()}个',
                                      TextStyle(
                                        color:
                                            isDark
                                                ? colorScheme.onSurface
                                                : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (
                                      double value,
                                      TitleMeta meta,
                                    ) {
                                      return _getMonthlyBottomTitles(
                                        context,
                                        value,
                                        meta,
                                      );
                                    },
                                    reservedSize: 18,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (
                                      double value,
                                      TitleMeta meta,
                                    ) {
                                      return _getLeftTitles(
                                        context,
                                        value,
                                        meta,
                                      );
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: _getMonthlyBarGroups(),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 2,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: theme.dividerColor.withOpacity(0.15),
                                    strokeWidth: 0.5,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                            ),
                            swapAnimationDuration: const Duration(
                              milliseconds: 500,
                            ),
                            swapAnimationCurve: Curves.easeInOutCubic,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getMonthlyBarGroups() {
    final colorScheme = Theme.of(context).colorScheme;

    return _monthlyStats.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final count = item['count'].toDouble();
      final month = item['month'] as DateTime;

      // 判断是否是当前月
      final isCurrentMonth = _isCurrentMonth(month);

      // 根据计数和是否是当前月设置颜色
      Color barColor;
      if (count == 0) {
        barColor = colorScheme.secondary.withOpacity(0.3);
      } else if (isCurrentMonth) {
        barColor = colorScheme.tertiary;
      } else {
        barColor = colorScheme.secondary;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count,
            color: barColor,
            width: 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxMonthlyValue() * 1.2,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _getMonthlyBottomTitles(
    BuildContext context,
    double value,
    TitleMeta meta,
  ) {
    final index = value.toInt();
    if (index >= 0 && index < _monthlyStats.length) {
      final month = _monthlyStats[index]['month'] as DateTime;
      final isCurrentMonth = _isCurrentMonth(month);

      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 3,
        child: SizedBox(
          height: 13,
          child: ClipRect(
            child: Text(
              DateFormat('M月').format(month),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.w500,
                color:
                    isCurrentMonth
                        ? Theme.of(context).colorScheme.secondary
                        : null,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _getLeftTitles(BuildContext context, double value, TitleMeta meta) {
    if (value == 0) {
      return const SizedBox();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 3,
      child: Text(
        value.toInt().toString(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  double _getMaxMonthlyValue() {
    if (_monthlyStats.isEmpty) return 10;
    final max =
        _monthlyStats
            .map((item) => item['count'] as int)
            .reduce((max, value) => max > value ? max : value)
            .toDouble();
    return max > 0 ? max : 10;
  }

  int _getMonthlyTotal() {
    if (_monthlyStats.isEmpty) return 0;
    return _monthlyStats
        .map((item) => item['count'] as int)
        .reduce((sum, value) => sum + value);
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  Widget _buildMonthlyDetailList() {
    if (_monthlyStats.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('没有月度数据')),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '月度详情',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(_monthlyStats.length, (index) {
              final item = _monthlyStats[index];
              final month = item['month'] as DateTime;
              final count = item['count'] as int;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('M').format(month),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy年M月').format(month),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '完成 ${count == 0 ? "没有" : count.toString()} 个番茄钟',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            count > 0
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: count > 0 ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _historyList.isEmpty ? _buildEmptyHistory() : _buildHistoryList();
  }

  Widget _buildEmptyHistory() {
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
        itemCount: dates.length + 1, // 额外项目用于底部间距
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          if (index == dates.length) {
            // 创建一个底部空白
            return const SizedBox(height: 40);
          }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕宽度确定布局策略
        final isNarrow = constraints.maxWidth < 400;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child:
                  isNarrow
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '共 ${items.length} 个，${_getFormattedDuration(totalDuration)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                      : Row(
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
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '共 ${items.length} 个，${_getFormattedDuration(totalDuration)}',
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
      },
    );
  }

  Widget _buildHistoryItem(PomodoroHistory item) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task =
        item.taskId != null
            ? taskProvider.getTaskById(int.parse(item.taskId!))
            : null;

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
                Icon(
                  Icons.timer,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                  item.status == 'completed' ? '已完成' : '已中断',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        item.status == 'completed'
                            ? Colors.green
                            : Colors.orange,
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

  // 添加这个辅助方法来处理类型转换
  String _getFormattedDuration(dynamic duration) {
    int minutes;
    if (duration is int) {
      minutes = duration;
    } else {
      minutes = duration.toInt();
    }

    if (minutes < 60) {
      return '$minutes 分钟';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours 小时';
    }

    return '$hours 小时 $remainingMinutes 分钟';
  }

  // 构建空图表状态
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 40, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
