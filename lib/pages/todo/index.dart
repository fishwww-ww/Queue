import 'package:flutter/material.dart';
import 'dart:io';
import 'package:queue/utils/storage.dart';
import 'package:queue/utils/dates.dart';
import 'package:queue/widgets/common/delete_completed_action.dart';
import 'package:queue/widgets/common/bucket_section.dart';

// 优先级配色方案
class PriorityColors {
  // 执行 - 温暖的红色，表示紧急但不刺眼
  static const Color execute = Color(0xFFE57373); // 浅红色

  // 暂缓 - 温暖的黄色，表示中等优先级
  static const Color defer = Color(0xFFFFB74D); // 浅橙色

  // 搁置 - 清新的绿色，表示低优先级
  static const Color hold = Color(0xFF81C784); // 浅绿色
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<_TodoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<File> _getStorageFile() async => getDocFile('todos.json');

  Future<void> _loadItems() async {
    try {
      final file = await _getStorageFile();
      if (await file.exists()) {
        final list = await loadJsonList('todos.json');
        setState(() {
          _items = list.map((e) => _TodoItem.fromJson(e)).toList();
        });
      } else {
        // 无本地数据时，初始化为空列表，不写入示例数据
        setState(() {
          _items = [];
        });
      }
    } catch (_) {
      // 读取失败时不崩溃，使用空列表
      setState(() {
        _items = [];
      });
    }
  }

  Future<void> _saveItems() async {
    try {
      await _getStorageFile();
      await saveJsonList('todos.json', _items.map((e) => e.toJson()).toList());
    } catch (_) {
      // 忽略写入错误
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('大 Todo'),
      actions: [
        DeleteCompletedAction(
          hasCompleted: _items.any((e) => e.completed),
          onDeleteCompleted: () async {
            setState(() {
              _items = _items.where((e) => !e.completed).toList();
            });
            await _saveItems();
          },
        ),
      ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          BucketSection<_TodoItem>(
            title: '执行',
            priorityColor: PriorityColors.execute,
            allItems: _items,
            isInBucket: (it) => (it.bucket ?? _TodoBucket.execute) == _TodoBucket.execute,
            createNewItem: (title, dueAt) => _TodoItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              dueAt: dueAt,
              bucket: _TodoBucket.execute,
            ),
            onItemsChanged: (next) async {
              setState(() => _items = next);
              await _saveItems();
            },
            getId: (it) => it.id,
            getTitle: (it) => it.title,
            setTitle: (it, v) => it.title = v,
            getDueAt: (it) => it.dueAt,
            setDueAt: (it, v) => it.dueAt = v,
            getCompleted: (it) => it.completed,
            setCompleted: (it, v) => it.completed = v,
          ),
          const SizedBox(height: 8),
          BucketSection<_TodoItem>(
            title: '暂缓',
            priorityColor: PriorityColors.defer,
            allItems: _items,
            isInBucket: (it) => (it.bucket ?? _TodoBucket.execute) == _TodoBucket.defer,
            createNewItem: (title, dueAt) => _TodoItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              dueAt: dueAt,
              bucket: _TodoBucket.defer,
            ),
            onItemsChanged: (next) async {
              setState(() => _items = next);
              await _saveItems();
            },
            getId: (it) => it.id,
            getTitle: (it) => it.title,
            setTitle: (it, v) => it.title = v,
            getDueAt: (it) => it.dueAt,
            setDueAt: (it, v) => it.dueAt = v,
            getCompleted: (it) => it.completed,
            setCompleted: (it, v) => it.completed = v,
          ),
          const SizedBox(height: 8),
          BucketSection<_TodoItem>(
            title: '搁置',
            priorityColor: PriorityColors.hold,
            allItems: _items,
            isInBucket: (it) => (it.bucket ?? _TodoBucket.execute) == _TodoBucket.hold,
            createNewItem: (title, dueAt) => _TodoItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              dueAt: dueAt,
              bucket: _TodoBucket.hold,
            ),
            onItemsChanged: (next) async {
              setState(() => _items = next);
              await _saveItems();
            },
            getId: (it) => it.id,
            getTitle: (it) => it.title,
            setTitle: (it, v) => it.title = v,
            getDueAt: (it) => it.dueAt,
            setDueAt: (it, v) => it.dueAt = v,
            getCompleted: (it) => it.completed,
            setCompleted: (it, v) => it.completed = v,
          ),
        ],
      ),
          );
  }

  // 公共 BucketSection 已替换原实现
}

class _TodoItem {
  _TodoItem({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.bucket,
    this.completed = false,
  });

  final String id;
  String title;
  DateTime? dueAt;
  _TodoBucket? bucket;
  bool completed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueAt': dueAt != null ? _formatDateOnly(dueAt!) : null,
      'bucket': (bucket ?? _TodoBucket.execute).name,
      'completed': completed,
    };
  }

  static _TodoItem fromJson(Map<String, dynamic> json) {
    return _TodoItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      dueAt: _parseDateOnly(json['dueAt'] as String?),
      bucket: _parseBucket(json['bucket'] as String?),
      completed: json['completed'] as bool? ?? false,
    );
  }
}

String _formatDateOnly(DateTime date) => formatDateOnly(date);

DateTime? _parseDateOnly(String? value) => parseDateOnly(value);

enum _TodoBucket { execute, defer, hold }

_TodoBucket _parseBucket(String? name) {
  switch (name) {
    case 'execute':
      return _TodoBucket.execute;
    case 'defer':
      return _TodoBucket.defer;
    case 'hold':
      return _TodoBucket.hold;
    default:
      return _TodoBucket.execute;
  }
}
