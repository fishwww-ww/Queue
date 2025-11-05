import 'package:flutter/material.dart';

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
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day);
    });
  }

  String _formatDue(DateTime? time) {
    if (time == null) return '无截止时间';
    final y = time.year.toString().padLeft(4, '0');
    final m = time.month.toString().padLeft(2, '0');
    final d = time.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
                      '截止: ${_formatDue(_dueAt)}',
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


