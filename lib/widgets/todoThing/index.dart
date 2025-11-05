import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queue/widgets/todoModal/index.dart';

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
  });

  final String title;
  final DateTime? dueAt;
  final bool completed;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onExpand;
  final ValueChanged<TodoEditResult>? onEdited;
  final Widget? dragHandle;

  String _formatDue(DateTime? time) {
    if (time == null) return '无截止时间';
    final y = time.year.toString().padLeft(4, '0');
    final m = time.month.toString().padLeft(2, '0');
    final d = time.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
              border: Border.all(color: Theme.of(context).dividerColor),
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
                  Theme.of(context).hintColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            // 勾选框
            Checkbox(
              value: completed,
              onChanged: onChanged,
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
                            decoration: completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '截止: ${_formatDue(dueAt)}',
                    style: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            // 编辑按钮
            IconButton(
              icon: const Icon(Icons.edit_outlined),
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


