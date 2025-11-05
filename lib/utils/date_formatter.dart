class DateFormatter {
  // 获取星期几的中文名称
  static String getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '';
    }
  }

  // 智能格式化日期显示
  static String formatDueDate(DateTime? time) {
    if (time == null) return '无截止时间';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(time.year, time.month, time.day);

    if (dueDate.isAtSameMomentAs(today)) {
      return '今天';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      return '明天';
    } else {
      // 显示月-日 和 周几
      final month = time.month.toString().padLeft(2, '0');
      final day = time.day.toString().padLeft(2, '0');
      final weekday = getWeekdayName(time.weekday);
      return '$month-$day $weekday';
    }
  }

  // 格式化日期显示（带前缀）
  static String formatDueDateWithPrefix(DateTime? time, {String prefix = '截止: '}) {
    if (time == null) return '无截止时间';
    return '$prefix${formatDueDate(time)}';
  }
}