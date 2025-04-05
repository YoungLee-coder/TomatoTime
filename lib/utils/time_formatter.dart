import 'package:intl/intl.dart';

class TimeFormatter {
  // 格式化秒数为 mm:ss 格式
  static String formatSeconds(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 格式化分钟为 小时:分钟 格式 (例如 1:30)
  static String formatMinutes(int minutes) {
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

  // 格式化日期为 yyyy年MM月dd日 格式
  static String formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日').format(date);
  }

  // 格式化日期为简短日期格式 (例如 2023年7月15日)
  static String formatShortDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日').format(date);
  }

  // 格式化日期为 yyyy-MM-dd 格式
  static String formatDateToISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 格式化日期为完整日期格式，包含星期 (例如 2023年7月15日 星期六)
  static String formatFullDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(date);
  }

  // 格式化为时间 (例如 14:30)
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // 格式化为日期时间 (例如 2023年7月15日 14:30)
  static String formatDateTime(DateTime dateTime) {
    return '${formatShortDate(dateTime)} ${formatTime(dateTime)}';
  }

  // 格式化日期时间为 MM-dd HH:mm 格式
  static String formatShortDateTime(DateTime dateTime) {
    return DateFormat('MM-dd HH:mm').format(dateTime);
  }

  // 格式化为相对时间（如：刚刚、5分钟前、1小时前、昨天、等）
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else if (difference.inDays < 2) {
      return '昨天 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} 周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} 个月前';
    } else {
      return '${(difference.inDays / 365).floor()} 年前';
    }
  }

  // 获取星期几
  static String getWeekday(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = date.weekday - 1; // weekday从1开始（1是周一）
    return weekdays[weekday];
  }

  // 判断是否是今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // 获取智能日期显示（今天、昨天、日期）
  static String getSmartDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else {
      return formatShortDate(date);
    }
  }

  // 计算两个日期的差异，返回可读字符串
  static String getTimeDifference(DateTime start, DateTime end) {
    final difference = end.difference(start);

    if (difference.inDays > 0) {
      return '${difference.inDays} 天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} 小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} 分钟前';
    } else {
      return '刚刚';
    }
  }
}
