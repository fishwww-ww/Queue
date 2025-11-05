import 'package:flutter/material.dart';
import 'package:queue/utils/dates.dart';
import 'package:queue/utils/date_formatter.dart';

class TodoEditResult {
  TodoEditResult({required this.title, this.dueAt});
  final String title;
  final DateTime? dueAt;
}

class TodoEditModal extends StatefulWidget {
  const TodoEditModal({
    super.key,
    required this.initialTitle,
    this.initialDueAt,
  });

  final String initialTitle;
  final DateTime? initialDueAt;

  @override
  State<TodoEditModal> createState() => _TodoEditModalState();
}

class _TodoEditModalState extends State<TodoEditModal> {
  late final TextEditingController _titleController;
  DateTime? _dueAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _dueAt = widget.initialDueAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    // 显示底部选择器
    final result = await showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DateTimePickerSheet(initialDate: _dueAt),
    );

    if (result != null) {
      setState(() {
        _dueAt = DateTime(result.year, result.month, result.day);
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '待办内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormatter.formatDueDateWithPrefix(_dueAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.event),
                    label: const Text('选择时间'),
                  ),
                  const SizedBox(width: 8),
                  if (_dueAt != null)
                    TextButton(
                      onPressed: () => setState(() => _dueAt = null),
                      child: const Text('清除'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        TodoEditResult(title: _titleController.text.trim(), dueAt: _dueAt),
                      );
                    },
                    child: const Text('保存'),
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

// 日期时间选择器底部弹窗
class _DateTimePickerSheet extends StatelessWidget {
  const _DateTimePickerSheet({required this.initialDate});

  final DateTime? initialDate;

  // 获取星期几的中文名称
  String _getWeekdayName(int weekday) {
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

  // 快速选项数据
  List<_QuickOption> _getQuickOptions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // 找到本周日（如果今天是周日，则今天就是本周日）
    int daysUntilSunday = (7 - now.weekday) % 7;
    if (daysUntilSunday == 0) daysUntilSunday = 7; // 如果今天是周日，则下周日
    final thisSunday = today.add(Duration(days: daysUntilSunday));

    return [
      _QuickOption(
        title: '今天',
        subtitle: _getWeekdayName(now.weekday),
        date: today,
        icon: Icons.today,
      ),
      _QuickOption(
        title: '明天',
        subtitle: _getWeekdayName(tomorrow.weekday),
        date: tomorrow,
        icon: Icons.next_week,
      ),
      _QuickOption(
        title: '本周日',
        // 本周日对应的日期, 精确到日就行, 不要时间, 不需要年份
        subtitle: formatDateOnly(thisSunday).substring(5),
        date: thisSunday,
        icon: Icons.event_available,
      ),
      _QuickOption(
        title: '选择日期',
        subtitle: '自定义选择日期',
        date: null,
        icon: Icons.calendar_month,
        showDatePicker: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final quickOptions = _getQuickOptions();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '选择截止日期',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 快速选项列表
          ...quickOptions.map((option) => _buildOptionTile(context, option)),

          // 底部按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, _QuickOption option) {
    final isSelected = option.date != null &&
        initialDate != null &&
        option.date!.year == initialDate!.year &&
        option.date!.month == initialDate!.month &&
        option.date!.day == initialDate!.day;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          option.icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        option.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      subtitle: option.subtitle != null
          ? Text(
              option.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () async {
        if (option.showDatePicker) {
          // 显示日期选择器
          final now = DateTime.now();
          final date = await showDatePicker(
            context: context,
            initialDate: initialDate ?? now,
            firstDate: DateTime(now.year - 1),
            lastDate: DateTime(now.year + 5),
          );
          if (date != null) {
            if (context.mounted) {
              Navigator.of(context).pop(date);
            }
          }
        } else if (option.date != null) {
          // 直接选择快速选项
          Navigator.of(context).pop(option.date);
        }
      },
    );
  }
}

// 快速选项数据类
class _QuickOption {
  const _QuickOption({
    required this.title,
    this.subtitle,
    this.date,
    required this.icon,
    this.showDatePicker = false,
  });

  final String title;
  final String? subtitle;
  final DateTime? date;
  final IconData icon;
  final bool showDatePicker;
}


