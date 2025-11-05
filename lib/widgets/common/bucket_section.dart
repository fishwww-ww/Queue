import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queue/widgets/todoThing/index.dart';
import 'package:queue/widgets/todoModal/index.dart';

class BucketSection<T> extends StatelessWidget {
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
  });

  final String title;
  final List<T> allItems;
  final bool Function(T item) isInBucket;
  final T Function(String title, DateTime? dueAt) createNewItem;
  final Future<void> Function(List<T> next) onItemsChanged;

  final String Function(T item) getId;
  final String Function(T item) getTitle;
  final void Function(T item, String value) setTitle;
  final DateTime? Function(T item) getDueAt;
  final void Function(T item, DateTime? value) setDueAt;
  final bool Function(T item) getCompleted;
  final void Function(T item, bool value) setCompleted;

  @override
  Widget build(BuildContext context) {
    final sectionItems = allItems.where(isInBucket).toList();
    final sectionIndices = [
      for (int i = 0; i < allItems.length; i++)
        if (isInBucket(allItems[i])) i
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: '添加',
                icon: const Icon(Icons.add_circle_outline),
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
                    final List<T> next = List<T>.from(allItems);
                    next.add(createNewItem(result.title, result.dueAt));
                    await onItemsChanged(next);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // 自定义拖拽预览样式，确保显示圆角
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Colors.black.withOpacity(0.3),
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
              final List<T> next = List<T>.from(allItems);
              
              // 将重新排序后的分组项替换到 allItems 中对应的位置
              // sectionIndices 包含了 allItems 中属于当前分组的所有索引
              // 按照 sectionIndices 的顺序，用重新排序后的项替换
              for (int i = 0; i < sectionIndices.length && i < reorderedSectionItems.length; i++) {
                next[sectionIndices[i]] = reorderedSectionItems[i];
              }
              
              await onItemsChanged(next);
            },
            itemCount: sectionItems.length,
            itemBuilder: (ctx, localIndex) {
              final item = sectionItems[localIndex];
              return Container(
                key: ValueKey(getId(item)),
                // margin: const EdgeInsets.symmetric(vertical: 8),
                child: TodoThingCard(
                  title: getTitle(item),
                  dueAt: getDueAt(item),
                  completed: getCompleted(item),
                  onChanged: (v) async {
                    setCompleted(item, v ?? false);
                    await onItemsChanged(List<T>.from(allItems));
                  },
                  onEdited: (res) async {
                    setTitle(item, res.title);
                    setDueAt(item, res.dueAt);
                    await onItemsChanged(List<T>.from(allItems));
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
          ),
        ],
      ),
    );
  }
}


