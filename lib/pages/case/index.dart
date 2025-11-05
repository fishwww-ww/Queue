import 'package:flutter/material.dart';
import 'dart:io';
import 'package:queue/utils/storage.dart';
import 'package:queue/utils/dates.dart';
import 'package:queue/widgets/common/delete_completed_action.dart';
import 'package:queue/widgets/common/bucket_section.dart';

class CasePage extends StatefulWidget {
  const CasePage({super.key});

  @override
  State<CasePage> createState() => _CasePageState();
}

class _CasePageState extends State<CasePage> {
  List<_CaseItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<File> _getStorageFile() async => getDocFile('cases.json');

  Future<void> _loadItems() async {
    try {
      final file = await _getStorageFile();
      if (await file.exists()) {
        final list = await loadJsonList('cases.json');
        setState(() {
          _items = list.map((e) => _CaseItem.fromJson(e)).toList();
        });
      } else {
        // 无本地数据时，初始化为空列表
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
      await saveJsonList('cases.json', _items.map((e) => e.toJson()).toList());
    } catch (_) {
      // 忽略写入错误
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('小 Case'),
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
          BucketSection<_CaseItem>(
            title: '执行',
            allItems: _items,
            isInBucket: (it) => (it.bucket ?? _CaseBucket.execute) == _CaseBucket.execute,
            createNewItem: (title, dueAt) => _CaseItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              dueAt: dueAt,
              bucket: _CaseBucket.execute,
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
          BucketSection<_CaseItem>(
            title: '暂缓',
            allItems: _items,
            isInBucket: (it) => (it.bucket ?? _CaseBucket.execute) == _CaseBucket.defer,
            createNewItem: (title, dueAt) => _CaseItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              dueAt: dueAt,
              bucket: _CaseBucket.defer,
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
          BucketSection<_CaseItem>(
            title: '搁置',
            allItems: _items,
            isInBucket: (it) => (it.bucket ?? _CaseBucket.execute) == _CaseBucket.hold,
            createNewItem: (title, dueAt) => _CaseItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              dueAt: dueAt,
              bucket: _CaseBucket.hold,
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

class _CaseItem {
  _CaseItem({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.bucket,
    this.completed = false,
  });

  final String id;
  String title;
  DateTime? dueAt;
  _CaseBucket? bucket;
  bool completed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueAt': dueAt != null ? _formatDateOnly(dueAt!) : null,
      'bucket': (bucket ?? _CaseBucket.execute).name,
      'completed': completed,
    };
  }

  static _CaseItem fromJson(Map<String, dynamic> json) {
    return _CaseItem(
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

enum _CaseBucket { execute, defer, hold }

_CaseBucket _parseBucket(String? name) {
  switch (name) {
    case 'execute':
      return _CaseBucket.execute;
    case 'defer':
      return _CaseBucket.defer;
    case 'hold':
      return _CaseBucket.hold;
    default:
      return _CaseBucket.execute;
  }
}

