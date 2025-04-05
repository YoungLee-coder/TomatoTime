import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatisticsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
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
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const WeeklyChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '本周番茄钟统计',
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
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '总计: ${_getTotalCount()}个',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child:
                  data.isEmpty
                      ? _buildEmptyState(context)
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          // 确保图表宽度足够大以支持滚动
                          width: max(
                            MediaQuery.of(context).size.width - 32,
                            data.length * 60.0,
                          ),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _getMaxY() * 1.2,
                              minY: 0,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipPadding: EdgeInsets.all(8),
                                  tooltipRoundedRadius: 8,
                                  tooltipMargin: 8,
                                  tooltipBgColor:
                                      isDark
                                          ? colorScheme.surface
                                          : colorScheme.primary,
                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    return BarTooltipItem(
                                      '${rod.toY.toInt()}个',
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
                                      return _getBottomTitles(
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
                              barGroups: _getBarGroups(context),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 40, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            '本周暂无数据',
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

  List<BarChartGroupData> _getBarGroups(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final count = item['count'].toDouble();

      // 判断是否是周末
      final date = item['date'] as DateTime;
      final isWeekend = date.weekday == 6 || date.weekday == 7;
      final color = isWeekend ? secondaryColor : primaryColor;

      // 根据计数使用不同的饱和度
      final actualColor = count > 0 ? color : color.withOpacity(0.15);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count,
            color: actualColor,
            width: 14,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY() * 1.2,
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _getBottomTitles(BuildContext context, double value, TitleMeta meta) {
    final index = value.toInt();
    if (index >= 0 && index < data.length) {
      final date = data[index]['date'] as DateTime;
      final isToday = _isToday(date);

      return SideTitleWidget(
        axisSide: meta.axisSide,
        angle: 0,
        space: 3,
        child: SizedBox(
          height: 13,
          child: ClipRect(
            child: Text(
              DateFormat('E').format(date),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                color:
                    isToday
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
      angle: 0,
      space: 8,
      child: Text(
        value.toInt().toString(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 5;
    final max =
        data
            .map((item) => item['count'] as int)
            .reduce((max, value) => max > value ? max : value)
            .toDouble();
    return max > 0 ? max : 5;
  }

  int _getTotalCount() {
    if (data.isEmpty) return 0;
    return data
        .map((item) => item['count'] as int)
        .reduce((sum, value) => sum + value);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
