import 'package:flutter/material.dart';
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
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;
              final List<int> newOrder = List<int>.from(sectionIndices);
              final moved = newOrder.removeAt(oldIndex);
              newOrder.insert(newIndex, moved);

              final List<T> next = List<T>.from(allItems);
              for (int k = 0; k < newOrder.length; k++) {
                next[newOrder[k]] = allItems[sectionIndices[k]];
              }
              await onItemsChanged(next);
            },
            itemCount: sectionItems.length,
            itemBuilder: (ctx, localIndex) {
              final item = sectionItems[localIndex];
              return Container(
                key: ValueKey(getId(item)),
                margin: const EdgeInsets.only(bottom: 6),
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
                    child: Icon(Icons.drag_handle, color: Theme.of(context).hintColor),
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


