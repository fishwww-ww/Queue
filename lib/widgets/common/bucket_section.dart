import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queue/widgets/todoThing/index.dart';
import 'package:queue/widgets/todoModal/index.dart';

class BucketSection<T> extends StatefulWidget {
  const BucketSection({
    super.key,
    required this.title,
    required this.allItems,
    required this.isInBucket,
    required this.createNewItem,
    required this.onItemsChanged,
    required this.getId,
    required this.getTitle,
    required this.setTitle,
    required this.getDueAt,
    required this.setDueAt,
    required this.getCompleted,
    required this.setCompleted,
    this.initiallyExpanded = true,
    this.priorityColor,
  });

  final String title;
  final List<T> allItems;
  final bool Function(T item) isInBucket;
  final T Function(String title, DateTime? dueAt) createNewItem;
  final Future<void> Function(List<T> next) onItemsChanged;
  final bool initiallyExpanded;
  final Color? priorityColor;

  final String Function(T item) getId;
  final String Function(T item) getTitle;
  final void Function(T item, String value) setTitle;
  final DateTime? Function(T item) getDueAt;
  final void Function(T item, DateTime? value) setDueAt;
  final bool Function(T item) getCompleted;
  final void Function(T item, bool value) setCompleted;

  @override
  State<BucketSection<T>> createState() => _BucketSectionState<T>();
}

class _BucketSectionState<T> extends State<BucketSection<T>> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Color _getPriorityColor(BuildContext context) {
    if (widget.priorityColor != null) {
      return widget.priorityColor!;
    }
    // 默认使用主题色
    return Theme.of(context).colorScheme.primary;
  }

  Color _getLightVariant(Color color) {
    // 生成颜色的浅色变体，用于背景
    final hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(0.98).withSaturation(0.3).toColor();
  }

  Color _getBorderVariant(Color color) {
    // 生成边框颜色
    final hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(0.85).withSaturation(0.4).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final sectionItems = widget.allItems.where(widget.isInBucket).toList();
    final sectionIndices = [
      for (int i = 0; i < widget.allItems.length; i++)
        if (widget.isInBucket(widget.allItems[i])) i
    ];

    final priorityColor = _getPriorityColor(context);
    final backgroundColor = _getLightVariant(priorityColor);
    final borderColor = _getBorderVariant(priorityColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      tooltip: _isExpanded ? '收起' : '展开',
                      icon: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: priorityColor,
                        ),
                      ),
                      onPressed: _toggleExpanded,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '添加',
                icon: Icon(
                  Icons.add_circle_outline,
                  color: priorityColor,
                ),
                onPressed: () async {
                  final result = await showModalBottomSheet<TodoEditResult>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (ctx) => const TodoEditModal(
                      initialTitle: '',
                    ),
                  );
                  if (result != null && result.title.isNotEmpty) {
                    final List<T> next = List<T>.from(widget.allItems);
                    next.add(widget.createNewItem(result.title, result.dueAt));
                    await widget.onItemsChanged(next);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: _isExpanded
                      ? const NeverScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  // 自定义拖拽预览样式，确保显示圆角
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: child,
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) async {
                    // 调整 newIndex：当向下拖拽时，需要减1
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    // 重新排列当前分组内的项目
                    final List<T> reorderedSectionItems = List<T>.from(sectionItems);
                    final T movedItem = reorderedSectionItems.removeAt(oldIndex);
                    reorderedSectionItems.insert(newIndex, movedItem);

                    // 构建新的 allItems 列表，保持原有顺序但更新当前分组的顺序
                    final List<T> next = List<T>.from(widget.allItems);

                    // 将重新排序后的分组项替换到 allItems 中对应的位置
                    // sectionIndices 包含了 allItems 中属于当前分组的所有索引
                    // 按照 sectionIndices 的顺序，用重新排序后的项替换
                    for (int i = 0; i < sectionIndices.length && i < reorderedSectionItems.length; i++) {
                      next[sectionIndices[i]] = reorderedSectionItems[i];
                    }

                    await widget.onItemsChanged(next);
                  },
                  itemCount: sectionItems.length,
                  itemBuilder: (ctx, localIndex) {
                    final item = sectionItems[localIndex];
                    return Container(
                      key: ValueKey(widget.getId(item)),
                      // margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TodoThingCard(
                        title: widget.getTitle(item),
                        dueAt: widget.getDueAt(item),
                        completed: widget.getCompleted(item),
                        priorityColor: priorityColor,
                        onChanged: (v) async {
                          widget.setCompleted(item, v ?? false);
                          await widget.onItemsChanged(List<T>.from(widget.allItems));
                        },
                        onEdited: (res) async {
                          widget.setTitle(item, res.title);
                          widget.setDueAt(item, res.dueAt);
                          await widget.onItemsChanged(List<T>.from(widget.allItems));
                        },
                        dragHandle: ReorderableDragStartListener(
                          index: localIndex,
                          child: SvgPicture.asset(
                            'lib/assets/drag.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).hintColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


