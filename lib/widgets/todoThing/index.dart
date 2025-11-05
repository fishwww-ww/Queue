import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queue/widgets/todoModal/index.dart';
import 'package:queue/utils/date_formatter.dart';

class TodoThingCard extends StatelessWidget {
  const TodoThingCard({
    super.key,
    required this.title,
    this.dueAt,
    this.completed = false,
    this.onChanged,
    this.onExpand,
    this.onEdited,
    this.dragHandle,
    this.priorityColor,
  });

  final String title;
  final DateTime? dueAt;
  final bool completed;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onExpand;
  final ValueChanged<TodoEditResult>? onEdited;
  final Widget? dragHandle;
  final Color? priorityColor;

  
  Color _getCardColor(BuildContext context) {
    if (priorityColor != null) {
      // 使用优先级颜色的极浅版本作为背景
      final hslColor = HSLColor.fromColor(priorityColor!);
      return hslColor.withLightness(0.97).withSaturation(0.2).toColor();
    }
    return Theme.of(context).colorScheme.surface;
  }

  Color _getBorderColor(BuildContext context) {
    if (priorityColor != null) {
      // 使用优先级颜色的浅版本作为边框
      final hslColor = HSLColor.fromColor(priorityColor!);
      return hslColor.withLightness(0.85).withSaturation(0.3).toColor();
    }
    return Theme.of(context).dividerColor;
  }

  Color _getTextColor(BuildContext context) {
    if (priorityColor != null) {
      // 使用优先级颜色的深色版本作为文字颜色
      final hslColor = HSLColor.fromColor(priorityColor!);
      return hslColor.withLightness(0.25).toColor();
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    if (priorityColor != null) {
      // 使用优先级颜色的中等版本作为次要文字颜色
      final hslColor = HSLColor.fromColor(priorityColor!);
      return hslColor.withLightness(0.45).toColor();
    }
    return Theme.of(context).hintColor;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardColor = _getCardColor(context);
    final borderColor = _getBorderColor(context);
    final textColor = _getTextColor(context);
    final secondaryTextColor = _getSecondaryTextColor(context);

    return ClipRRect(
      // 关键：裁剪容器的矩形边界，让布局和视觉一致
      // 这样拖拽时移动的就是圆角形状，而非矩形
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // spacing: const Gap(8),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cardColor,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 拖拽手柄（可由上层传入可拖拽句柄）
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: dragHandle ?? SvgPicture.asset(
                'lib/assets/drag.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  secondaryTextColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            // 勾选框
            Checkbox(
              value: completed,
              onChanged: onChanged,
              activeColor: priorityColor,
            ),
            // 内容与截止时间
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: secondaryTextColor,
                            decoration: completed ? TextDecoration.lineThrough : null,
                            decorationColor: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormatter.formatDueDateWithPrefix(dueAt),
                    style: textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                  ),
                ],
              ),
            ),
            // 编辑按钮
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: priorityColor ?? textColor,
              ),
              onPressed: () async {
                if (onExpand != null) {
                  onExpand!();
                }
                final result = await showModalBottomSheet<TodoEditResult>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (ctx) => TodoEditModal(
                    initialTitle: title,
                    initialDueAt: dueAt,
                  ),
                );
                if (result != null && onEdited != null) {
                  onEdited!(result);
                }
              },
              tooltip: '编辑',
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}


